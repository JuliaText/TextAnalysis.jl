using Unicode: normalize

using WordTokenizers: TokenBuffer, isdone, flush!, character, spaces, atoms

function isinvalid(c)
  if c == '\t' || c == '\n' || c == '\r'
    return false
  end
  c == Char(0) || c == Char(0xfffd) || iscntrl(c)
end

"""
    invalid(ts)

ignore invalid characters such like U+0000, U+fffd, and Control characters
"""
function invalid(ts)
  isinvalid(ts[]) || return false
  ts.idx += 1
  return true
end

ischinese(c) =
  Char(0x4e00)  ≤ c ≤ Char(0x9fff)  ||
  Char(0x3400)  ≤ c ≤ Char(0x4dbf)  ||
  Char(0x20000) ≤ c ≤ Char(0x2a6df) ||
  Char(0x2a700) ≤ c ≤ Char(0x2b73f) ||
  Char(0x2b740) ≤ c ≤ Char(0x2b81f) ||
  Char(0x2b820) ≤ c ≤ Char(0x2ceaf) ||
  Char(0xf900)  ≤ c ≤ Char(0xfaff)  ||
  Char(0x2f800) ≤ c ≤ Char(0x2fa1f)


"""
    chinese(ts)

separate on chinese characters
"""
function chinese(ts)
  ischinese(ts[]) || return false
  flush!(ts, string(ts[]))
  ts.idx += 1
  return true
end

isbertpunct(c) = ispunct(c) ||
  Char(33)  ≤ c ≤ Char(47)  ||
  Char(58)  ≤ c ≤ Char(64)  ||
  Char(91)  ≤ c ≤ Char(96)  ||
  Char(123) ≤ c ≤ Char(126)

#=
albert basic tokenizer pipeline
skip 1. convert to unicode
2. clean text
3. handle chinese character
4. tokenize with white space
5. if lower case : lower, NFD normalize, skip 'Mn' unicode on each tokens
6. split each token with punct and punct remain

=#
function tokenise(input, ::Val{lower}) where lower
  ts = TokenBuffer(lower ? normalize(lowercase(input), :NFD) : input)
  while !isdone(ts)
    lower(ts) ||
    chinese(ts)   ||
    spaces(ts)    ||
    character(ts)
  end
  return (ts.tokens)
end



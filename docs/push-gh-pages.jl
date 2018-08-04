#Adapted from https://github.com/github/developer.github.com/blob/master/Rakefile#L21-L48

#Run this file from its current directory to build the documentation and push the result into gh-pages

last_commit=readchomp(`git --no-pager log -1 --pretty=format:"%h:%s"`)

ENV["GIT_DIR"]=abspath(chomp(readstring(`git rev-parse --git-dir`)))

old_sha = chomp(readstring(`git rev-parse refs/remotes/origin/gh-pages`))

#run(`julia make.jl`)

cd("build") do

    gif="/tmp/dev.gh.i"
    ENV["GIT_INDEX_FILE"]=gif
    ENV["GIT_WORK_TREE"]=pwd()
    run(`git add -A`)
    tsha=chomp(readstring(`git write-tree`))
    mesg="Deploy docs for master@$last_commit" 

    if length(old_sha) == 40
        csha = chomp(readstring(`git commit-tree $tsha -p $old_sha -m $(mesg)`))
    else 
        csha = chomp(readstring(`git commit-tree $tsha -m $(mesg)`))
    end

     print("Created commit $csha")

     run(`git --no-pager show $csha --stat`)

     run(`git update-ref refs/heads/gh-pages $csha `)

     run(`git push origin gh-pages `)

end

# minimize `-log(p(y|X))`
function crf_loss(a::CRF, input_seq, label_seq)


    loss = 0

    for (input, label) in zip(input_seq, label_seq)
        loss += preds_single(a, input)
    end
end

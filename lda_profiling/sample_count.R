library('ggplot2')

df <- read.csv('lda_inference.csv', header = FALSE)
names(df) <- c('Case', 'Samples', 'BetaError', 'ThetaError')

ggplot(df, aes(x = Samples, y = BetaError)) +
  geom_point()

ggplot(df, aes(x = Samples, y = BetaError)) +
  geom_point() +
  stat_summary(fun.data = 'mean_cl_boot', geom = 'point') +
  stat_summary(fun.data = 'mean_cl_boot', geom = 'errorbar')

ggplot(df, aes(x = Samples, y = ThetaError)) +
  geom_point()

ggplot(df, aes(x = Samples, y = ThetaError)) +
  geom_point() +
  stat_summary(fun.data = 'mean_cl_boot', geom = 'point') +
  stat_summary(fun.data = 'mean_cl_boot', geom = 'errorbar') +
  geom_hline(yintercept = 0.5)

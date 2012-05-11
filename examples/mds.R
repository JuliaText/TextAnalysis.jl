dm <- read.csv("dm.csv", header = FALSE)
dm <- as.matrix(dm)

mds <- cmdscale(dm)

mds <- as.data.frame(mds)
names(mds) <- c('X', 'Y')

mds <- transform(mds, Year = 1776 + 1:nrow(mds))

mds <- subset(mds, Year != '1916')

ggplot(mds, aes(x = X, y = Y)) +
  geom_text(aes(label = Year))
ggplot(mds, aes(x = Year, y = X)) +
  geom_point()
ggplot(mds, aes(x = Year, y = Y)) +
  geom_point()

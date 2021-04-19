MyDice_sum <- function(y, Size){
  dice <- sample(1:y, size, replace = TRUE)
  return(sum(dice))
  cat( "Total of Dices value",Sum(dice),"/n" )
  MyDice_sum1(dice,y)
}
MyDice.sum1 <- function(dice, y){
if (length(y)<11){
Count <- Sum(length(dice[dice>6]))
cat("count of numbers that greater than 6:", Count )
}
else {
Count_d <- sum(length(dice[dice>16]))
cat("count of numbers that greater than 16:", Count_d )
}
}
MyDice_sum (1:10,6)
MyDice_sum (1:20,6)


----------------------------------
>MyDice_sum (1:20,6)
[1] 17 16 6 20 10 15
Total of Dices value: 84
count of numbers that greater than 16: 2

```
#!/usr/loccal/bin/R

#install essential packages
install.packages("rJava",dependencies=TRUE)
install.packages("xlsx",dependencies=TRUE)
install.packages("sqldf",dependencies=TRUE)
install.packages("corrplot",dependencies=TRUE)
install.packages("leaps",dependencies=TRUE)
install.packages("lmtest",dependencies=TRUE)

library(rJava)
library(sqldf)

#setting workstation
setwd("/home/steven/workstation")
#source data loaded
library(xlsx)
src <- read.xlsx("/usr/local/workstation/test.xls",1,encoding="UTF-8")
#drop columns that is useless
src <- src[,-c(1)]
src <- src[,c(1:6,8:10,7)]

#1、description statistic
attach(src)
names(src)
mean=sapply(src,mean)
max=sapply(src,max)
min=sapply(src,min)
median=sapply(src,median)
sd=sapply(src,sd)
cbind(mean,max,min,median,sd)
#1、参数全部默认情况下的相关系数图
#混合方法之上三角为圆形，下三角为黑色数字
library(corrplot)

corr <- cor(src[,1:10])
corrplot(corr = corr,order="AOE",type="upper",tl.pos="tp")
corrplot(corr = corr,add=TRUE, type="lower", 
         method="number",order="AOE", col="black",
         diag=FALSE,tl.pos="n", cl.pos="n")

#2.画相关图选择回归方程的形式
#par(mfrow=c(2,4))

plot(target~cg);abline(lm(target~cg))
plot(target~h);abline(lm(target~h))
plot(target~type);abline(lm(target~type))
plot(target~tjg);abline(lm(target~tjg))
plot(target~ggjg);abline(lm(target~ggjg))
plot(target~area);abline(lm(target~area))
plot(target~cs);abline(lm(target~cs))
plot(target~yyjg);abline(lm(target~yyjg))
plot(target~rs);abline(lm(target~rs))
#3.do regression and check results
dim(src)[1]
lm.test<-lm(target~rs+cs+area+type+cg+h+tjg+ggjg+yyjg,data=src)
summary(lm.test)
#4.delete variable which is not significant(rs,area)
lm.test<-lm(target~cs+type+cg+h+tjg+ggjg+yyjg,data=src)
summary(lm.test)
#4.1.use residual analysis delete outlier points
plot(lm.test,which=1:4)
src = src[-c(12,765,788,790),]
dim(src)[1]
#regression stepwise
#HP = step(lm)
#lm1 = lm(target~rs+cs+area+type+cg+h+tjg+ggjg+yyjg,data=src)
#summary(lm.test)
#lm2 = step(lm1)



#5.1GQtest，H0（误差平方与自变量，自变量的平方和其交叉相都不相关），
#p值很小时拒绝H0，认为上诉公式有相关性，存在异方差
src.test<-residuals(lm.test)
library(lmtest)
gqtest(lm.test)

#5.2BPtest,H0(同方差),p值很小时认为存在异方差
bptest(lm.test)

#两个检验的p值都很小时认为存在异方差
#6.修正异方差
#修正的方法选择FGLS即可行广义最小二乘
#6.1修正步骤
#6.1.1将y对xi求回归，算出res--u
#6.1.2计算log(u^2)
#6.1.3做log(u^2)对xi的辅助回归 log(u^2),得到拟合函数g=b0+b1x1+..+b2x2
#6.1.4计算拟合权数1/h=1/exp(g)，并以此做wls估计

lm.test2<-lm(log(resid(lm.test)^2)~cs+type+cg+h+tjg+ggjg+yyjg,data=src)
lm.test3<-lm(target~cs+type+cg+h+tjg+ggjg+yyjg,weights=1/exp(fitted(lm.test2)),data=src)
summary(lm.test3)

#7.1计算解释变量相关稀疏矩阵的条件数k，k<100多重共线性程度很小，100<k<1000较强，>1000严重
src[1:9]
XX<-cor(src[1:9])
kappa(XX)

#7.2寻找共线性强的解释变量组合
#用于发现共线性强的解释变量组合#
eigen(XX)


#8.修正多重共线性---逐步回归法
step(lm.test)

#subsets regression
library(leaps)
leaps = regsubsets(log(target)~cs+type+cg+h+tjg+ggjg+yyjg,data=src)
summary(leaps)
plot(leaps,scale="bic")
#then select variables base on bic value

#ps2：step中可进行参数设置：direction=c("both","forward","backward")来选择逐步回归
#的方向，默认both，forward时逐渐增加解释变两个数，backward则相反。
```

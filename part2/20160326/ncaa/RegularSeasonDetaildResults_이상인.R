#���� �ε�
RegularDetailedResults <- read.csv("RegularSeasonDetailedResults.csv",header=T)

#attach(RegularDetailedResults)
names(RegularDetailedResults)

#�¸�/�й� ���� Į�� �ε��� �з�
idx.common<-c(1,2,7,8)
idx.w<-c(3,4,9,10,11,12,13,14,15,16,17,18,19,20,21)
idx.l<-c(5,6,22,23,24,25,26,27,28,29,30,31,32,33,34)
#RegularDetailedResults$Numot<-as.factor(RegularDetailedResults$Numot)

win<-RegularDetailedResults[,c(idx.common,idx.w)]
lose<-RegularDetailedResults[,c(idx.common,idx.l)]

#�¸��� ���� 1, �й��� ���� 1�� ���
win$Result<-rep(1,nrow(win))
lose$Result<-rep(0,nrow(lose))

#win, lose ���̺� rbind ���� �÷� �̸� ������
names(win)<-rep(NA,ncol(win))
names(lose)<-rep(NA,ncol(lose))
by.team<-rbind(win,lose)
names(by.team)<-c("Season","Daynum","Wloc","Numot","Team","Score","Fgm","Fga",
                   "Fgm3","Fga3","Ftm","Fta","Or","Dr","Ast","To","Stl","Blk","Pf",
                   "Result")

#���� ��� �� ��� �� �������� �̷���� ���� ����
by.team<-by.team[by.team$Numot==0,]

#2�� �� �õ�, ���� ���� ���(�ʵ��-3����)
by.team$Fga2<-by.team$Fga-by.team$Fga3
by.team$Fgm2<-by.team$Fgm-by.team$Fgm3

by.team<-tbl_df(by.team)

#summarise(group_by(by.team,Team,Season),count=n())

#����, ���𺰷� ��� ��� aggregate
agg<-aggregate(cbind(Score,Fgm2,Fga2,Fgm3,Fga3,Ftm,Fta,Or,Dr,Ast,To,Stl,Blk,Pf,Result)~Season+Team,
               by.team,FUN=mean)

#2003-2011��������� train, 2012-2015��������� test�� �з�
train<-agg[agg$Season %in% seq(2003,2011),]
test<-agg[agg$Season %in% seq(2012,2015),]


#�������� ��� ����� �������� �·��� ���� ȸ�ͺм�
summary(lm(Result~Fgm2+Fga2+Fgm3+Fga3+Ftm+Fta+Or+Dr+Ast+To+Stl+Blk+Pf,train))
step(lm(Result~1,data=train),
     scope=list(lower=~1,upper=~Fgm2+Fga2+Fgm3+Fga3+Ftm+Fta+Or+Dr+Ast+To+Stl+Blk+Pf)
                                      ,direction='both')
#Call:
#lm(formula = Result ~ To + Ftm + Dr + Stl + Fga2 + Fgm2 + Fga3 + 
#     Or + Fgm3 + Fta + Blk, data = train)

#Coefficients:
#  (Intercept)           To          Ftm           Dr          Stl         Fga2         Fgm2         Fga3  
#0.509176    -0.045055     0.023165     0.039483     0.052300    -0.047079     0.051920    -0.049893  
#Or         Fgm3          Fta          Blk  
#0.044290     0.082790    -0.013048     0.003421  

#ȸ�ͺм����� ������ ���� �������� 2012-2015���� �·� ����
test$Pred<-predict(lm(Result~To+Ftm+Dr+Stl+Fga2+Fgm2+Fga3+Or+Fgm3+Fta+Blk,train),newdata=test)

#���� �·����� ���� ���
test$Error<-test$Pred-test$Result

#head(test[,c("Result","Pred","Error")],30)

#������ ���� ��հ� ǥ������
c(mean(test$Error),sd(test$Error))

#############################################################################################################
TourneyDetailedResults <- read.csv("TourneyDetailedResults.csv",header=T)
TourneyTeamList<-unique(c(TourneyDetailedResults$Wteam, TourneyDetailedResults$Lteam))

#2003-2015���𵿾� ��ʸ�Ʈ�� ������ ������ �ڷḸ�� �������� ���� (agg1)
agg1<-agg[agg$Team %in% TourneyTeamList,]

train<-agg1[agg1$Season %in% seq(2003,2011),]
test<-agg1[agg1$Season %in% seq(2012,2015),]

summary(lm(Result~Fgm2+Fga2+Fgm3+Fga3+Ftm+Fta+Or+Dr+Ast+To+Stl+Blk+Pf,train))
step(lm(Result~1,data=train),
     scope=list(lower=~1,upper=~Fgm2+Fga2+Fgm3+Fga3+Ftm+Fta+Or+Dr+Ast+To+Stl+Blk+Pf)
     ,direction='both')

#step���� ä�õ� �����鸸���� ȸ�͸� ����
test$Pred<-predict(lm(Result~Ast+To+Ftm+Dr+Stl+Fga2+Fgm2+Fga3+Or+Fgm3+Fta,train),newdata=test)

#���� �·����� ���� ���
test$Error<-test$Pred-test$Result

c(mean(test$Error),sd(test$Error))


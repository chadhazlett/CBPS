\name{CBMSM}
\alias{CBMSM}
\alias{CBMSM.fit}
\title{Covariate Balancing Propensity Score (CBPS) for Marginal Structural Models}
\description{
  \code{CBMSM} estimates propensity scores such that both covariate balance and prediction of treatment assignment are maximized.  With longitudinal data, the method returns marginal structural model weights that can be entered directly into a linear model.  The method also handles multiple binary treatments administered concurrently.}
\usage{
	  CBMSM(formula, id, time, data, type="MSM", twostep = TRUE, 
			msm.variance = "approx", time.vary = FALSE, ...)
	  CBMSM.fit(treat, X, id, time, MultiBin.fit, twostep,
				msm.variance, time.vary, ...)
}
\arguments{
  \item{formula}{A list of formulas of the form treat ~ X.  The function assumes that there is one formula for each time, and they are ordered from the first time to the last time.}
  \item{id}{A vector which identifies the unit associated with each row of treat and X.}
  \item{time}{A vector which identifies the time period associated with each row of treat and X.}
  \item{data}{An optional data frame, list or environment (or object coercible by as.data.frame to a data frame) containing the variables in the model. If not found in data, the variables are taken from \code{environment(formula)}, typically the environment from which \code{CBMSM} is called.}
  \item{twostep}{Set to \code{TRUE} to use a two-step estimator, which will run substantially faster than continuous-updating.  Default is \code{FALSE}, which uses the continuous-updating estimator described by Imai and Ratkovic (2014).}
  \item{msm.variance}{Default is \code{FALSE}, which uses the low-rank approximation of the variance described in Imai and Ratkovic (2014).  Set to \code{TRUE} to use the full variance matrix.}
  \item{time.vary}{Default is \code{FALSE}, which uses the same coefficients across time period.  Set to \code{TRUE} to fit one set per time period.}
  \item{treat}{A vector of treatment assignments.  For N observations over T time periods, the length of treat should be N*T.}
  \item{X}{A covariate matrix.  For N observations over T time periods, X should have N*T rows.}
  \item{type}{"MSM" for a marginal structural model, with multiple time periods or "MultiBin" for multiple binary treatments at the same time period.}
  \item{MultiBin.fit}{A parameter for whether the multiple binary treatments occur concurrently (\code{FALSE}) or over consecutive time periods (\code{TRUE}) as in a marginal structural model.  Setting type = "MultiBin" when calling \code{CBMSM} will set MultiBin.fit to \code{TRUE} when CBMSM.fit is called.}
  \item{...}{Other parameters to be passed through to \code{optim()}}
}
\details{Fits covariate balancing propensity scores for marginal structural models.}
\value{
  \item{weights}{The optimal weights.}
  \item{fitted.values}{The fitted propensity score for each observation.}
  \item{y}{The treatment vector used.}
  \item{x}{The covariate matrix.}
  \item{id}{The vector id used in CBMSM.fit.}
  \item{time}{The vector time used in CBMSM.fit.}
  \item{model}{The model frame.}
  \item{call}{The matched call.}
  \item{formula}{The formula supplied.}
  \item{data}{The data argument.}
  \item{treat.hist}{A matrix of the treatment history, with each observation in rows and time in columns.}
  \item{treat.cum}{A vector of the cumulative treatment history, by individual.}
}

\references{

Imai, Kosuke and Marc Ratkovic.  2014. ``Covariate Balancing
Propensity Score.'' Journal of the Royal Statistical Society, Series B
(Statistical
Methodology). \url{http://imai.princeton.edu/research/CBPS.html}
	
Imai, Kosuke and Marc Ratkovic.  2015.  ``Robust Estimation of Inverse
Probability Weights for Marginal Structural Models.''  Journal of the
American Statistical Association. \url{http://imai.princeton.edu/research/MSM.html} 

}

\author{Marc Ratkovic, Christian Fong, and Kosuke Imai; The CBMSM function is based on the code for version 2.15.0 of the glm function implemented in the stats package, originally written by Simon Davies.  This documenation is likewise modeled on the documentation for glm and borrows its language where the arguments and values are the same.}

\seealso{\link{plot.CBMSM}}

\examples{

##Load Blackwell data

data(Blackwell)

## Quickly fit a short model to test
form0 <- "d.gone.neg ~ d.gone.neg.l1 + camp.length"
fit0<-CBMSM(formula = form0, time=Blackwell$time,id=Blackwell$demName,
			data=Blackwell, type="MSM",  iterations = NULL, twostep = TRUE, 
			msm.variance = "approx", time.vary = FALSE)

\dontrun{
##Fitting the models in Imai and Ratkovic  (2014)		
##Warning: may take a few mintues; setting time.vary to FALSE
##Results in a quicker fit but with poorer balance
##Usually, it is best to use time.vary TRUE
form1<-"d.gone.neg ~ d.gone.neg.l1 + d.gone.neg.l2 + d.neg.frac.l3 + 
		camp.length + camp.length + deminc + base.poll + year.2002 + 
		year.2004 + year.2006 + base.und + office"
		
fit1<-CBMSM(formula = form1, time=Blackwell$time,id=Blackwell$demName,
			data=Blackwell, type="MSM",  iterations = NULL, twostep = TRUE, 
			msm.variance = "full", time.vary = TRUE)

fit2<-CBMSM(formula = form1, time=Blackwell$time,id=Blackwell$demName,
			data=Blackwell, type="MSM",  iterations = NULL, twostep = TRUE, 
			msm.variance = "approx", time.vary = TRUE)


##Assessing balance

bal1<-balance.CBMSM(fit1)
bal2<-balance.CBMSM(fit2)

##Effect estimation: Replicating Effect Estimates in 
##Table 3 of Imai and Ratkovic (2014)

lm1<-lm(demprcnt[time==1]~fit1$treat.hist,data=Blackwell,
weights=fit1$glm.weights)
lm2<-lm(demprcnt[time==1]~fit1$treat.hist,data=Blackwell,
weights=fit1$weights)
lm3<-lm(demprcnt[time==1]~fit1$treat.hist,data=Blackwell,
weights=fit2$weights)

lm4<-lm(demprcnt[time==1]~fit1$treat.cum,data=Blackwell,
weights=fit1$glm.weights)
lm5<-lm(demprcnt[time==1]~fit1$treat.cum,data=Blackwell,
weights=fit1$weights)
lm6<-lm(demprcnt[time==1]~fit1$treat.cum,data=Blackwell,
weights=fit2$weights)



### Example: Multiple Binary Treatments Administered at the Same Time
n<-200
k<-4
set.seed(1040)
X1<-cbind(1,matrix(rnorm(n*k),ncol=k))

betas.1<-betas.2<-betas.3<-c(2,4,4,-4,3)/5
probs.1<-probs.2<-probs.3<-(1+exp(-X1 \%*\% betas.1))^-1

treat.1<-rbinom(n=length(probs.1),size=1,probs.1)
treat.2<-rbinom(n=length(probs.2),size=1,probs.2)
treat.3<-rbinom(n=length(probs.3),size=1,probs.3)
treat<-c(treat.1,treat.2,treat.3)
X<-rbind(X1,X1,X1)
time<-c(rep(1,nrow(X1)),rep(2,nrow(X1)),rep(3,nrow(X1)))
id<-c(rep(1:nrow(X1),3))
y<-cbind(treat.1,treat.2,treat.3) \%*\% c(2,2,2) + 
X1 \%*\% c(-2,8,7,6,2) + rnorm(n,sd=5)

multibin1<-CBMSM(treat~X,id=id,time=time,type="MultiBin",twostep=TRUE)
summary(lm(y~-1+treat.1+treat.2+treat.3+X1, weights=multibin1$w))
}
}
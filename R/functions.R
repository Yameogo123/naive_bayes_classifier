

#for discretization
# library("discretization")
# library("RWeka")
# #for mca - pca - famd
# library("FactoMineR")
# #for dataframe manip
# library("dplyr")
# #for encoding, score
# library("caret")
# #for parallel
#library("doParallel")
# #visualisation
# library("factoextra")


registerDoParallel(cores=detectCores() %>% -1)

# This script regroup all of necessaries functions for our naive bayes different types of implementation (it can be seen as a controller)


### - will check if an output (y) is a list of character. Usefull for controls.
check_output <- function(output){
  return (is.character(output))
}



### complete function of what naive bayes default value should look like

## depreciate (will be used directly in R6Class)

#alpha = 1 its for laplace

naive_bayes_default <- function(x, y, alpha=1){
  registerDoParallel(cores=detectCores() %>% -1)

  target= as.factor(y)
  probsY= prop.table(table(target))
  probsY= as.data.frame(t(probsY)) %>% select(-"Var1")
  probsY["probs"]= probsY["Freq"]
  probsY["Freq"]= NULL
  probsY= data.frame(probsY, row.names = "target")

  #1- treat numeric
  #get numeric and treat gauss
  num= sapply(x, is.numeric)
  if(sum(num)!=0){
    res= proba_cond_gauss(x[num], y)
  }else{
    res= NULL
  }

  #2- treat categorical
  mat= as.matrix(x[!num])
  funct <- function(xi) {
    var <- x[,xi]
    tab <- table(var, y, dnn = c(xi, "")) + alpha
    tab= list(xi=prop.table(tab, margin =2))
    names(tab)<-c(xi)
    tab
  }
  #, simplify = FALSE)
  #if()
  tables= foreach(m=colnames(mat), .combine = c, .multicombine=TRUE) %dopar% (funct(m))
  cond= list(char=tables, num=res)
  return (list(cond=cond, prior= as.matrix(probsY)))
}

naive_bayes_gauss <- function(x, y, alpha=1){
  #pior probabilities (not linked to multi)
  target= as.factor(y)
  level= levels(target)
  probsY= prop.table(table(target))
  probsY= as.data.frame(t(probsY)) %>% select(-"Var1")
  probsY["probs"]= probsY["Freq"]
  probsY["Freq"]= NULL
  probsY= data.frame(probsY, row.names = "target")

  #mat= as.matrix(x)

  res= proba_cond_gauss(x, y)
  return (list(cond=res, prior= as.matrix(probsY)))
}

### bernoulli
naive_bayes_bern <- function(x, y, alpha){
  #pior probabilities (not linked to multi)
  target= as.factor(y)
  level= levels(target)
  probsY= prop.table(table(target))
  probsY= as.data.frame(t(probsY)) %>% select(-"Var1")
  probsY["probs"]= probsY["Freq"]
  probsY["Freq"]= NULL
  probsY= data.frame(probsY, row.names = "target")

  mat= as.matrix(x)

  #warn_ing(message = "our bernoulli return probas for 1 only. To get for 0 its just 1-proba_of_1", cond = T)
  res= proba_cond_bernoulli(mat, y, alpha)
  return (list(cond=res, prior= as.matrix(probsY)))
}




### - multinomial naive bayes
naive_bayes_multinomial <- function(x, y=NULL, smooth=1, prior= NULL){
  target= as.factor(y)
  if(is.null(prior)){
    prior= prop.table(table(target))
  }

  #sum by column of each y (with smoothness added)
  params <- rowsum(x, y, na.rm = TRUE) + smooth
  #sum of the sum by group to know all words
  params <- params / colSums(params)

  proba= t(params)

  niveau= levels(target)
  colnames(proba)= niveau

  return (list(cond=proba, prior=prior))

}




### - conditionnal probabilities calculation for categorical / mean and standard deviation for numeric

# -> Description:
###### this is the probabilities of xi knowing y (P(xi=k/y=c)) for categorical vars
######## if xi as 2  factors its a Bernoulli probability
######## else we will count with table and prop table
###### if vars are numeric and their distribution follows the gaussian law we will calculate mean and sd conditionnaly to y


# -> parameters:
###### x is one column among predictive variables columns of the dataset. it's either categorical or numeric
###### y is the knowing group (outcome) of our model. It has the same length as x. And for each line of x we have his corresponding group in y.(categorical)
###### smooth is a value between 0 and 1 useful specially to avoid null probabilities. Null probabilities will cause bias in the model. By default we keep it to Laplace smoothing (meaning 1)

# -> result:
###### the function will return either a condionnal probabilities for categorical vars or conditionnal mean and standard deviation (sd)


#for gauss
# we will use the log formula of the gaussian distribution
proba_cond_gauss<- function(x, y=NULL){
  #his levels
  y_levels= levels(as.factor(y))
  compte= table(factor(y))
  #nam= colnames(x)
  # funct<-function(v){
  #   inter= mat[y==v, ]
  #   moy= colMeans(inter)
  #   ecart= sqrt((inter-moy)^2/nrow(inter))
  #   return (rbind(moy, ecart))
  # }
  # inter= foreach(v=y_levels, .combine = rbind) %dopar% funct(v)
  mu <- rowsum(x, y, na.rm = TRUE) / compte
  #sum((xi-mu)^2)= sum(xi^2-2ximu+ mu2)= sum(xi^2) - 2mu^2*sum(1) + mu^2*sum(1) = sum(xi^2) - mu^2*n
  #then we correct it by dividing with (n-1)
  sd <- sqrt((rowsum(x^2, y, na.rm = TRUE) - mu^2 * compte) / ( compte - 1))
  warn_ing(message = "your datas as nan standard deviation (one column with the some values maybe) that makes it difficult to work with", cond = any(is.na(sd)))
  inter= list(mu = as.matrix(mu), sd = as.matrix(sd))
  return (inter)
}


#for categorical: table and prob table will do the trick
#--> will do it for one column only
proba_cond_categorical <- function(x, y=NULL, smooth=1){
  res= table(x, y)+smooth
  tab= prop.table(res, 2)
  return (tab)
}


#will return proba for 1 classes only
proba_cond_bernoulli <- function(x, y, alpha=1){
  p_x_y= function(i){
    rr= table(x[,i], y) + alpha
    rr= prop.table(rr, margin=2)["1",]
    return (rr)
  }
  rs= foreach(m= 1:ncol(x), .combine = rbind) %dopar% p_x_y(m)
  rownames(rs) = colnames(x)
  return (rs)
}



### - predict new data probabilities'

# -> Description:
###### knowing the model, we can predict the possible outcome on a dataset
######## we will multiply prior probabilities (probabilities of different possibilities of our target values(the outcome)) with all the others conditional probabilities


# -> parameters:
###### model is the naive bayes model trained on data (probabilities)
###### priors (y probabilities by factor)
###### newdata is the dataframe of data we want to make the prediction on. These dataframes columns names must be same as the trained one.

# -> result:
###### the outcome will be the probabilitites conditionnally to the target var

predict_proba_default <- function(model, priors, newdata){
  colonnes<- colnames(newdata)
  log_priors= log(t(priors))
  log_sum <- matrix(log_priors, ncol = nrow(priors), nrow = nrow(newdata), byrow = TRUE)
  classes = rownames(priors)
  colnames(log_sum) <- classes

  #go through each columns and add is log prob to the previous one
  for (var in colonnes) {
    #get the element of var column in the newdata set
    vals <- newdata[[var]]
    if (is.numeric(vals)){
      mu <- model$num$mu[,var]
      sd <- model$num$sd[,var]
      sd[sd <= 0] <- 0.001
      #parallelisation working slowly here
      p_x_y <- sapply(seq_along(classes), function(index) {
        #on applique notre log_gauss et on prends son expo
        exp(log_gauss(vals, mu[index], sd[index]))
      })
      #if there are 0 probability add a noise to avoid 0 result
      p_x_y[p_x_y <= 0] <- 0.001
      if (is.na(var)) p_x_y[is.na(p_x_y)] <- 1
      #sum it up with the
      log_sum <- log_sum + log(p_x_y)
    }else{
      #get p_x_y categorical model by var
      tab <- model$char[[var]]
      tab <- log(tab)
      if (is.na(var)) {
        logp <- tab[vals, ]
        logp[is.na(var)] <- 0
        log_sum <- log_sum + logp

      }else {
        log_sum <- log_sum + tab[vals, ]
      }
    }
  }
  #conditionnal probabilities
  #fin= foreach(cl=1:nrow(priors), .combine = cbind) %dopar% (1 / rowSums(exp(rs - rs[,cl])))
  #colnames(fin)= rownames(priors)
  fin= exp(log_sum) / rowSums(exp(log_sum))
  return (fin)
}



## predict for gaussian naive bayes
predict_proba_gauss <- function(model, priors, newdata, classes){
  log_priors= log(priors)
  sd= as.matrix(model[["sd"]])
  mu= as.matrix(model[["mu"]])
  #cant work with nul standard deviation as the division will be infinite value
  # so we give it a threshold of 10^-3
  sd[sd <= 0] <- 0.001
  #
  #????
  eps <- log(.Machine$double.xmin)
  threshold <- log(0.001)
  interm<- function(c) {
    #appliy function log_gauss
    rs= log_gauss(as.matrix(t(newdata)), mu[c,], sd[c,])
    #if if null probability, use a really small epsilon
    rs[rs <= eps] <- threshold
    reps <- colSums(rs) + log_priors[c,]
    return (reps)
  }

  result= foreach(m=classes, .combine = cbind) %dopar% interm(m)
  # weird exp(result)/ rowSums(exp(result)) is returning na values
  fin= foreach(m=1:length(classes), .combine = cbind) %dopar% (1 / rowSums(exp(result - result[,m])))
  colnames(fin)<- classes
  return (fin)

}

# predict bernoulli probs
predict_proba_bern <- function(model, priors, newdata){
  mt= as.matrix(newdata)
  prior= t(priors)
  proba_1= log(model)
  proba_0= log(1-model)
  # -> proba_1*x + proba_0*(1-x)
  nd <- mt %*% proba_1 + (1- mt) %*% proba_0
  #log_prio repeated on each row
  log_prio= matrix(log(prior), nrow = nrow(mt), ncol=ncol(prior), byrow = T)
  p= nd + log_prio
  rs= foreach(m=1:ncol(prior), .combine = cbind) %dopar% (1 / rowSums(exp(p - p[,m])))
  colnames(rs)= rownames(priors)
  #rs= exp(p)/rowSums(exp(p))
  return (rs)
}

### - predict for multinomial naive bayes

predict_proba_multi <- function(model, priors, newdata, classes=NULL){
  #lets work with logarithm first and then expo to come back at default state
  tb= tcrossprod(data.matrix(newdata), t(log(model)))
  tab= foreach(cl=1:length(classes), .combine = cbind) %dopar% (tb[ ,cl] + log(priors[[cl]]))
  colnames(tab) <- names(priors)
  #res= exp(tab) / rowSums(exp(tab))
  res= foreach(m=1:length(classes), .combine = cbind) %dopar% (1 / rowSums(exp(tab - tab[,m])))
  colnames(res)<- classes
  return (res)
}



### 4- gaussian likelihood

# -> Description:
###### gaussian distribution function.

# -> parameters:
###### xi a value we want to find the corresponding y value with the function
###### moy is the average of the distribution of X (condionnally to y) and ecart is the corresponding standard deviation

# -> result:
###### the outcome will be the probabilitites conditionnally to the target var

log_gauss <- function(xi, moy, ecart){
  #part_1= 1/sqrt(2*pi*ecart^2)
  #part_2= exp(-(xi-moy)^2/(2*ecart^2))
  #f_x= part_1 * part_2

  #with log applied we have
  f_x= -0.5 * (log(2 * pi) + 2* log(ecart)) - 0.5 * ((xi - moy) / ecart)^2
  return (f_x)
}



### 5- predict the class (group) of each row of the newdata

#version (will take directly the conditionnal probabilitites)
prediction<-function(probas, newdata, levels){
  maxi= apply(probas, 1, which.max)

  group= colnames(probas)[maxi]
  pred= as.matrix(group, ncol=1)
  colnames(pred) <- c("prediction")
  return (factor(pred, levels= levels))
}



### - Test if all numeric var distribution (with shapiro) are normal

#### h0: the var distribution is gaussian
#### h1: the distribution is not gaussian
#### x is the matrix on which the test will be done conditionnaly to y

# -> return
### will return the column of element to discretize

check_if_normal<- function(x, y, classes){
  #function "intermediaire" (sorry forgot the word in english)
  interm <- function(col){
    #var to check
    xx= x[y==col,]
    test= apply(xx, 2, function(xi){
      if(sum(xi)==0){
        F
      }else{
        shapiro.test(xi)[["p.value"]]>0.05
      }
    })
    return (test)
  }

  res= foreach(m=classes, .combine = rbind) %dopar% interm(m)
  #colnames(res) <- colnames(x)
  #var to discretize if non gaussian
  to.discretize= foreach(m= colnames(res), .combine = c) %dopar% (prod(res[,m])==0)
  return (colnames(x)[to.discretize])
}




### - discretization of qualitative variables

#modify mdlp function to allow it to take matrix as x and y as vector
mdlp_modified <- function (x, y)
{
  p = ncol(x)
  xd <- x
  cutp <- list()

  for (i in 1:p) {
    xi <- x[, i]
    cuts1 <- cutPoints(xi, y)
    cuts <- c(min(xi), cuts1, max(xi))
    cutp[[i]] <- cuts1
    if (length(cutp[[i]]) == 0) cutp[[i]] <- "All"
    xd[, i] <- as.character(as.integer(cut(xi, cuts, include.lowest = TRUE)))
    #xd[, i] <- cut(xi, cuts, include.lowest = TRUE)
  }
  return(list(cutp = cutp, Disc.data = xd))
}

discret.fit <- function(x, y){
  mdlp <- mdlp_modified(as.matrix(x), y)
  cutp= mdlp$cutp
  disc.data= mdlp$Disc.data
  cutp= lapply(cutp, function(xi) `if`(is.character(xi), c(-Inf, +Inf), c(-Inf, xi, +Inf)))
  return(list(cutp = cutp, disc.data = disc.data))
}


#fonction pour le déploiement
discret.transform <- function(objetDisc, newdata){
  #nombre de variables à traiter
  p <- length(objetDisc$cutp)
  resdata <- lapply(1:p, function(j){return(as.character(cut(newdata[,j], objetDisc$cutp[[j]], labels=FALSE)))})

  #transform into data.frame
  resdata <- data.frame(resdata)
  colnames(resdata) <- colnames(newdata)[1:p]
  return(list(codec=objetDisc$cutp, disc.data=resdata))
}



### - function to handle error

#### if condition is true will break everything and send a message
error <- function(message="stop !!", cond=T){
  if(cond){
    stop(message, call. = F)
  }
}

### - handle warnings
warn_ing <- function(message="warning !!", cond=T){
  if(cond){
    warning(message)
  }
}






#summary of both
# predict_multi <- function (model, priors, newdata, classes=NULL){
#   res= predict_proba_multi(model= model, priors= priors, newdata=newdata)
#   maxi= apply(res, 1, which.max)
#
#   group= colnames(res)[maxi]
#   pred= as.matrix(group, ncol=1)
#   colnames(pred) <- c("prediction")
#   return (as.factor(pred))
# }




### function for handling dimensional reduction with either pca, mca or famd

# fitting data
reduction.fit<- function(type="pca", dt=NULL, ncp= 5){
  if(type=="pca"){
    object= FactoMineR::PCA(dt, graph = FALSE, ncp= ncp)
  }else if(type=="mca"){
    object= FactoMineR::MCA(dt, graph = F, ncp= ncp)
  }else if(type=="famd"){
    object= FactoMineR::FAMD(dt, graph = F, ncp= ncp)
  }
  return (object)
}

# projecting new datas on the different axis
reduction.transform <- function(type="pca", object, newdata=NULL){
  if(type=="pca"){
    reduc= FactoMineR::predict.PCA(object, newdata)$coord
  }else if(type=="mca"){
    reduc= FactoMineR::predict.MCA(object, newdata)$coord
    object= FactoMineR::MCA(object, graph = F)
  }else if(type=="famd"){
    reduc= FactoMineR::predict.FAMD(object, newdata)$coord
  }
  return (data.frame(reduc))
}




### - get type of each col
get_type <- function(dt){
  type <- function(x){
    is_car= is.character(x) | is.factor(x)
    if(is_car){
      n_attrib= nlevels(as.factor(x))
      type= `if`(n_attrib==2, "bernoulli", "categorical")
    }else{
      type= "gaussian"
    }
    return (type)
  }
  rs= lapply(dt, type)

  return (rs)

}



### - encode variable with one_hot
encode.fit <- function(data){
  dummy <- dummyVars(" ~ .", data=data)
  return (dummy)
}

encode.transform <- function(object, newdata){
  dt <- data.frame(predict(object, newdata = newdata))
  return (dt)
}


### - score
score<-function(ypred, ytrue, positive_class="default"){
  tab= table(ypred, ytrue)
  if(positive_class!="default"){
    acc= confusionMatrix(tab, positive= positive_class)
  }else{
    acc= confusionMatrix(tab)
  }

  return (acc)
}

### facto visualisation
fact_viz<- function(object){
  #fviz_eig(object, addlabels = TRUE)
  # Graph of the variables
  #print("Graph of the variables ")
  fviz_pca_var(object, col.var = "cos2",
       gradient.cols = c("black", "orange", "green"),
       repel = TRUE)
  # Contribution of each variable
  #print("Contribution of each variable ")
  #fviz_cos2(object, choice = "var", axes = 1:2)
}





### complement naive bayes


complement_nb <- function(x, y, smooth=1, prior= NULL){
  target= as.factor(y)
  if(is.null(prior)){
    prior= prop.table(table(target))
  }
  params <- rowsum(x, y, na.rm = TRUE) + smooth
  rs= foreach(m=1:nrow(params), .combine=rbind) %dopar% (colSums(params[-n, ]) / sum(params[-m, ]))
  rownames(rs)<- rownames(params)
  proba= t(rs)
  return (list(cond=as.matrix(proba), priors= prior))
}


predict_proba_compl <- function(model, priors, newdata, classes=NULL){
  log_mod= t(log(model))
  #log_mod[which(!is.finite(log_mod))] <- 0

  #log priors
  log_prio= log(priors)
  #priors names

  tb= tcrossprod(data.matrix(newdata), log_mod)
  #ln_probs= log_prio - tb
  ln_probs= foreach(m=1:length(classes), .combine = cbind) %dopar% (log_prio[[m]] - tb[ ,-m])
  #res= foreach(n= 1:length(classes), .combine=cbind) %dopar% (1/rowSums(exp(ln_probs-as.vector(ln_probs[,n]))))
  res= exp(ln_probs) / rowSums(exp(ln_probs))
  colnames(res) <- classes

  return (res)
}















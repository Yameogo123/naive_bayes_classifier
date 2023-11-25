


#str mode storage.mode class summary

#library("R6")
#source('functions.R')




#' @title NaiveBayesClassifier
#'
#' @description
#' This is a package that implements in R6Class the naive bayes classifier algorithme with parallel execution
#' the available types for now are gaussian, default, multinomial, binomial
#'
#' @import R6
#' @import caret
#' @import doParallel
#' @import parallel
#' @import FactoMineR
#' @import discretization
#' @import factoextra
#' @import dplyr
#' @import foreach
#' @importFrom foreach %dopar%
#' @importFrom stats predict shapiro.test
#'
#' @examples
#' #obj= naive_bayes_classifier$new()
naive_bayes_classifier <- R6Class(

  "NaiveBayesClassifier",

  private = list(
    model= NULL,
    Xlabels= NULL,
    Ylevels= NULL,
    #smoothness to collide conditional values and avoid 0 probabilities (if 1 its laplace's smooth)
    smoothness= 0.5,
    #type of naive bayes to use
    type= "default",
    supported_type= c("default", "gaussian", "multinomial", "bernoulli"),# "complement"),
    fitted= FALSE,
    #vector of y probabilities (y column must correspond to the factors)
    priors= NULL,
    #apply dimensional reduction (can be null, mca, pca, famd)
    reduction= NULL,
    reduction.object= NULL,
    #number of component to keep (2 by default)
    n_components= NULL,
    #can be NULL, all, non-gaussian(will apply shapiro test if non gaussian), numeric (only to numeric)
    discretize= NULL,
    #can be NULL, one_hot
    encoding= NULL,
    encoding_object= NULL,
    #if discretize not NULL or not all, will save the vars to discretise here and applied discretize algo on test
    discretized_var= NULL,
    disc_object=NULL,
    #for multinomial version 1, we will keep the vocabulary for check matter
    vocabulary= NULL,
    #save X type by row
    x_types= NULL
  ),

  active= list(

    #' @field getModel Return the getter of conditionnal probabilites of X knowing y
    getModel = function(){
      return (private$model)
    },

    #' @field getPrior Return the getter of priors y informations
    getPrior= function(){
      return (private$priors)
    },

    #' @field getClasses Return the getter of Y levels
    getClasses= function(){
      return (private$Ylevels)
    }
  ),


  public = list(


    #' naive_bayes_classifier R6 init class
    #'
    #' @param type the type of naive algo you want to use (must be default, gaussian, bernoulli, multinomial or complement )
    #' @param smoothness is set to avoid 0 probability effect (if 1 it is laplace)
    #' @param priors null by default (it's the priors probabilities of Y)
    #' @param reduction null by default (can be pca, mca or famd to apply reduction analysis on our data)
    #' @param n_components 2 by default if reduction is set. To control your the number of components you keep for your fit
    #' @param discretize if you'd like to discretize your data. (from numeric to categoricals clusters) can be null, non-gaussian(to discretize non gaussian value by checking if normal with shapiro), all
    #'
    #'
    #' @return nothing (but will prepare the class to execute some tasks as fit, predict, and so on...)
    #'
    #' @examples
    #' #obj= naive_bayes_classifier$new(type="default")
    initialize=function(type="default", smoothness=1, priors= NULL, reduction=NULL, n_components= 2, discretize=NULL){#, encoding=NULL){
      #errors handler
      error("type must be one of: default gaussian multinomial, complement or bernoulli ", !is.element(type, private$supported_type))
      error(message = "smoothness must be greater or equal to 0", cond= (smoothness<0 | !is.numeric(smoothness)))
      if(!is.null(reduction))error(message = "reduction must be one of: NULL, pca, mca, famd", cond = !is.element(reduction, c("pca", "mca", "famd")))
      if(!is.null(discretize)) error(message = "discretize must be one of: NULL, all, non-gaussian, numeric", cond = !is.element(discretize, c("all", "non-gaussian", "numeric")))
      #if(!is.null(encoding)) error(message = "encoding must be one of: NULL, one_hot", cond = !is.element(encoding, c("one_hot")))
      if(!is.null(n_components)) error(message = "n_component must be >= 1", cond = !(n_components%%1==0 & n_components >= 1))
      # if(type!="multinomial" & type!="complement"){
      #   if(!is.null(encoding)){
      #     error(message = "either you discretize or encode your data! not both at the same time.", cond = !is.null(discretize))
      #     private$encoding= encoding
      #   }
      # }
      #vars initializing
      if(!is.null(priors)){
        error(message = "prior must be a dataframe", cond= !is.data.frame(priors))
        cond= is.element("probs", names(priors)) & ncol(priors)==1
        error(message = "priors must be a dataframe with one column named 'probs' that contains the conditionnal probabilities of Y and rows must be Y factors", cond = !cond)
        private$priors= priors
      }
      warn_ing(message="smoothness is usually between 0 and 1", cond= smoothness > 1)
      warn_ing(message= "your smoothness is 0 so you can end up with nan as predictive values if their are 0 in your conditional probabilities!!", cond= smoothness==0)
      private$type= type
      private$reduction= reduction
      private$smoothness= smoothness
      private$n_components = n_components
      private$discretize = discretize
      #private$encoding = encoding
    },

    #will fit the train datas to the giving parameters

    #'
    #' @param X dataframe/matrix object with data to form the model on.
    #' @param y the classes corresponding to X (must be a vector of characters with the same length as the number of X rows)
    #'
    #' @return will save the model (condtional probabilities of X by y) and the prior (y classes frequency)
    #'
    #' @examples
    #' #X= iris[,1:4]
    #' #y= iris[,-5]
    #' #obj$fit(X, y)
    fit = function(X, y){
      #check for possible error
      error(message = "y must contain character or factor values", cond = !(is.factor(y) | is.character(y)))
      error(message = "X must be dataframe or list type", cond = !(is.data.frame(X) | is.matrix(X)))
      error(message = "X and Y must have the same length", cond = nrow(as.data.frame(X))!=length(y))
      if(!is.element(private$type, c("multinomial", "complement"))) error(message = "Please give names to your dataframe/list labels!!", cond = is.null(names(data.frame(X))))
      error(message="Be aware of NAs in your database! Please impute or remove them first", cond= (sum(is.na(X))!=0 | sum(is.na(y))!=0))
      error(message = "Your Y must contain at least two class!", cond=length(unique(y))==1)
      if(private$type %in% c("gaussian", "default")) error(message = "Your Y must contain at least two observations by class!", cond=prod(table(y)>=2)==0)
      private$Xlabels = names(data.frame(X))
      private$Ylevels= levels(as.factor(y))
      if(private$type=="default") private$x_types= get_type(X)


      #traitement
      #discretize ?
      if(!is.null(private$discretize)){
        #our new dataset:
        warn_ing(message = "can take time if your database is very big", cond = T)
        if (private$discretize== "all"){
          error(message = "all of your values must be numeric to be discretized.", cond = prod(sapply(X, is.numeric))!=1)
          private$disc_object= discret.fit(X, y)
          df= private$disc_object$disc.data
          private$discretized_var= private$Xlabels
          X= as.data.frame(df)
        }else if (private$discretize=="non-gaussian"){
          quanti= data.frame(X) %>% select_if(is.numeric)
          nongauss= tryCatch(
            expr  = check_if_normal(data.matrix(quanti), y, private$Ylevels),
            error = function(e) {
              error(message = "at least one of y classes is present less than 3 times!! So shapiro-test can be applied!", cond=T)
            },
            finally= NULL
          )

          if(length(nongauss)>=1){
            warn_ing(message = paste0("the non-gaussian vars that has been discretized are: ", length(nongauss)), cond = TRUE)
            private$disc_object= discret.fit(quanti[nongauss], y)
            #df= data.frame(lapply(private$disc_object$disc.data, as.factor))
            df= private$disc_object$disc.data
            private$discretized_var= nongauss
            X[,nongauss]= df[,nongauss]
          }else{
            warn_ing(message = "all numerical variables follow a gaussian law so non has been discretized", cond = TRUE)
          }
        }else if(private$discretize=="numeric"){
          error(message = "you don't have numeric values in your database", cond = sum(sapply(X, is.numeric))==0)
          quanti= data.frame(X) %>% select_if(is.numeric)
          private$disc_object= discret.fit(quanti, y)
          df= data.frame(lapply(private$disc_object$disc.data, as.factor)) #%>% select(-y)
          private$discretized_var= colnames(df)
          X[,private$discretized_var]= df[,private$discretized_var]
        }
      }


      #dimensional reduction ?
      if(!is.null(private$reduction)){
        warn_ing(message = "be carefull about reduction you are working with multinomial/complement", cond= is.element(private$type, c("multinomial", "complement")))
        warn_ing(message = "you didn't precize n_components that corresponds to the number of components. (by default it will be 2)", cond= is.null(private$n_components))
        warn_ing(message = "can take time if your database is very big", cond = T)
        if(is.null(private$n_components) | private$n_components > length(private$Xlabels)){
          private$n_components = 2
        }
        if(private$reduction=="mca")error(message = "all values must be characters to apply mca", cond=prod(sapply(X, is.character))!=1)
        if(private$reduction=="pca")error(message = "all values must be numeric to apply pca", cond=prod(sapply(X, is.numeric))!=1)
        if(private$reduction=="famd")error(message = "you need to have as well as character and numeric values in your dataframe to apply famd", cond=(prod(sapply(X, is.numeric))==1 | prod(sapply(X, is.character))==1))
        private$reduction.object= reduction.fit(private$reduction, data.matrix(X), ncp=private$n_components)
        X= data.frame(private$reduction.object$ind$coord)
      }

      #last check if a column is the same
      #error(message = "one or many column(s) has the same value for all rows", cond = any(apply(X, 2, function(a) length(unique(a))==1)))

      #model application
      if(private$type=="default"){
        #application of default naive bayes.
        resultat=naive_bayes_default(X, y, private$smoothness)
      }else if(private$type=="gaussian"){
        error(message = "all of your values must be numeric", cond = prod(sapply(X, is.numeric))!=1)
        resultat=naive_bayes_gauss(X, y)
      }else if(private$type=="multinomial"){
        error(message = "your X must be a dataframe/list of numerical values (bag of word)", cond = prod(sapply(X, is.numeric))!=1 )
        private$vocabulary= colnames(X)
        resultat=naive_bayes_multinomial(X, y, smooth=private$smoothness, prior=private$priors)
      }else if(private$type=="complement"){
        error(message = "your X must be a dataframe/list of numerical values (bag of word)", cond = prod(sapply(X, is.numeric))!=1 )
        resultat= complement_nb(X, y, smooth=private$smoothness, prior=private$priors)
      }else if(private$type=="bernoulli"){
        error(message = "By column you must have two madalities!!", cond = prod(sapply(X, function(xi)nlevels(as.factor(xi))==2))!=1)
        #check if numeric and contain 1 or 0
        error(message = "all of your values must be numeric", cond = prod(sapply(X, is.numeric))!=1)
        error(message = "your values must be either 1 or 0", cond=prod(X == 1 | X == 0)!=1)
        resultat=naive_bayes_bern(X, y, private$smoothness)
      }
      private$model= resultat$cond
      if(is.null(private$priors)) private$priors= resultat$prior
      private$fitted = T
      #
    },

    #' @description
        #' to predict the probabilities of new data given to the model
    #'
    #' @param newdata must be of dataframe type
    #'
    #' @return the probabilities conditionnaly to y
    #'
    #' @examples
    #' #obj$predict_prob(X)
    predict_proba = function(newdata){
      error(cond=!private$fitted, message = "Please do the fit first before trying to predict on a dataset.")
      #traitement ?

      topred= names(newdata)

      #discretize new data ?
      if(!is.null(private$discretize)){
        if(!is.null(private$discretized_var)){
          error(message = "some vars that has been discretized are missing in newdata", cond = sum(topred %in% private$discretized_var) == length(topred))
          dt= discret.transform(private$disc_object, newdata = newdata[,private$discretized_var])$disc.data
          #dt= data.frame(lapply(dt, as.factor))
          newdata[,private$discretized_var]= dt[,private$discretized_var]
        }
      }


      verif= sum(topred %in% private$Xlabels) == length(topred)
      warn_ing(message = cat("some of the column you gave are unknown for the model and have been ignored: (", topred[!(topred %in% private$Xlabels)], ")\n"), cond = !verif)

      newdata= newdata[topred %in% private$Xlabels]

      #apply reduction transform on new data
      if(!is.null(private$reduction)){
        error(cond=sum(is.element(names(newdata), private$Xlabels))!= length(private$Xlabels), message = "newdata must have the same columns as your fitted X")
        newdata= reduction.transform(private$reduction, private$reduction.object, newdata = newdata)
      }

      if(is.element(private$type, c("multinomial", "complement", "gaussian", "bernoulli"))){
        error(cond=sum(is.element(names(newdata), private$Xlabels))!= length(private$Xlabels), message = "newdata must have the same columns as your fitted X")
      }

      if(private$type=="multinomial"){
        resultat= predict_proba_multi(model = private$model, priors= private$priors, newdata = newdata, classes=private$Ylevels)
      }else if(private$type=="complement"){
        resultat= predict_proba_compl(model = private$model, priors= private$priors, newdata = newdata, classes=private$Ylevels)
      }else if(private$type=="gaussian"){
        resultat= predict_proba_gauss(model = private$model, priors= private$priors, newdata = newdata, classes=private$Ylevels)
      }else if(private$type=="bernoulli"){
        resultat= predict_proba_bern(model = private$model, priors= private$priors, newdata = newdata)
      }else{
        error(cond=!is.data.frame(newdata), message = "newdata must be a dataframe.")
        #error(cond=sum(is.element(names(newdata), private$Xlabels))!= length(private$Xlabels), message = "newdata must have the same columns as your fitted X")

        #encode them if set ?
        #if(!is.null(private$encoding)){
          #newdata= encode.transform(private$encoding_object, newdata)
        #}

        resultat= predict_proba_default(model = private$model, priors= private$priors, newdata = newdata)
      }
      return (resultat)
    },


    #' @description
        #' will use conditional probabilities and select the classes of those wo had the biggest probabilities
    #'
    #' @param newdata must be of dataframe type
    #'
    #' @return the class of each row of your dataframe (it will just take the class of the biggest proba)
    #'
    #' @examples
    #' #obj$predict(X)
    predict= function(newdata){
      resultats= prediction(self$predict_proba(newdata), newdata, levels= private$Ylevels)
      return (resultats)
    },


    #'
    #' @param ...
    #'
    #' @return the result of class object after doing the fit. (you can see the type, priors probabilitites, the conditional ones, )
    #'
    #' @examples
    #' #obj$summary()
    summary = function(...){
      error(cond=!private$fitted, message = "Please do the fit first before trying to show summary.")
      cat("======================", sep="\n")
      cat("======================", sep="\n\n")
      cat("your algorithm type is: ", private$type)
      cat(sep="\n")
      cat("======================", sep="\n")
      cat("======================", sep="\n\n")
      cat("the priors probabilities are: ", sep="\n")
      print(private$priors)
      cat("======================", sep="\n")
      cat("======================", sep="\n\n")
      laplace= `if`(private$smoothness==1, "laplace", "")
      cat("the applied smoothness is ", private$smoothness, laplace)
      cat(sep="\n")
      cat("======================", sep="\n")
      cat("======================", sep="\n\n")
      if(private$type=="default"){
        cat("your basic model detail:", sep="\n")
        print(private$x_types)
        cat("======================", sep="\n")
        cat("======================", sep="\n\n")
      }
      cat("your model's details are: ", sep="\n")
      print(private$model)
    },


    #' @param ...
    #'
    #' @return some details informations about your class object
    #'
    #' @examples
    #' #obj$print()
    #' #print(obj)
    print = function(...) {
      cat("Naive bayes: ", private$type, "\n")
      cat("(supported naive bayes are: ", private$supported_type, ")\n")
      if(!is.element(private$type, c("multinomial", "complement")))cat("X labels: ", private$Xlabels, "\n")
      cat("Y levels: ", private$Ylevels, "\n")
      cat("reduction: ", `if`(is.null(private$reduction), "None", private$reduction), "\n", sep = "")
      cat("discretization:  ", `if`(is.null(private$discretize), "None", private$discretize), "\n", sep = "")
      #if(!is.element(private$type, c("multinomial", "complement"))) cat("vocabulary for multinomial/complement (1):  ", `if`(is.null(private$vocabulary), "None", private$vocabulary), "\n", sep = "")
    },

    #' @description
        #' (either you give it xtest and ytrue and it will do the prediction and evaluate it on ytrue or you give ytest and ytrue and it will give the evaluation)
    #'
    #' @param ypred the classes you predicted on a dataframe (result of predict function) (optionnal if you pass xtest)
    #' @param ytrue the true classes of the same dataframe you uses to have ypred (xtest)
    #' @param xtest the data to make the prediction on. (optional if you pass ypred already)
    #' @param positive_class give the classe that you'd like to make the focus on. (if not specified will act by default)
    #'
    #' @return evaluation of confusion matrix on the given data
    #' @export
    #' @examples
    #' #ypred= obj$predict(X)
    #' #ytrue= y
    #' #obj$evaluate(ypred= ypred, ytrue=ytrue, positive_class='Setosa')
    #' #obj$evaluate(xtest= X, ytrue=ytrue, positive_class='Setosa')
    evaluate = function(ypred=NULL, ytrue=NULL, xtest=NULL, positive_class= "default"){
      error(cond=!private$fitted, message = "Please do the fit first before trying to predict on a dataset.")
      error(cond=is.null(ytrue), message = "Please provide true y dataset.")
      error(cond=is.null(xtest) && is.null(ypred) , message = "Please provide at least xtest or y predicted dataset.")
      if(positive_class!="default") error(message = cat("positive class must be one of ", private$Ylevels, "\n"), cond = !is.element(positive_class, private$Ylevels))
      if(is.null(ypred)){
        ypred= self$predict(xtest)
      }
      sc= score(factor(ypred, levels = private$Ylevels), factor(ytrue, levels = private$Ylevels), positive_class=positive_class)
      return(sc)
    },


    #' @return the plot of pca or mca or famd components variables results
    #'
    #' @examples
    #' #obj$components_plot()
    components_plot= function(){
      error(cond=!private$fitted, message = "Please do the fit first before trying to predict on a dataset.")
      #cat("the reduction type is: ", private$reduction, "\n\n")
      #print("Graph of the variables: ")
      error(message = "there is no components detected", cond = !is.null(private$reduction))
      fact_viz(private$reduction.object)
    }

  )


)









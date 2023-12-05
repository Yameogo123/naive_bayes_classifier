


<h1><b>Naive Bayes Classifier </b></h1>

<br/>

<b>Type</b>: School project <br/>

<b>Participants</b>: 
<ul>
  <li> YAMEOGO Wendyam M. Ivan</li>
  <li> MAURIN Célia</li>
  <li> NICOULLAUD Albane</li>
</ul><br/>

<b>Teacher</b>: M. Ricco RAKOTOMALALA

<b>Degree</b>: SISE Master 

<br/>
<br/>


<h3> Introduction </h3>
<br/>

The Naive bayes his an algorithm that uses conditionnal probability to specify the chances of an event to occur knowing some informations. For instance:


| the weather | day type | wind level | the decision |
| :--------:  | :------: | :-------:  | :---------:  |
|    hot      | weekend  |   quiet    | play tennis  |
|    cold     | weekday  |   brutal   | stay home    |

<br/>

The probability to go <b>play tennis</b> will depends of the others informations we have (weather, day and the wind level).<br/>
So in order to decide in the future, like if its *cold* during the *weekend* and with *wind* will I be able to go *play* ? </br>
Naive Bayes will respond to that question by supposing that there is no link between these information. I mean it's not because it is the weekend that there is wind. So these informatives variables are not related. <br/>
But each of them has an impact on <b>the decision</b> so we can know:
<ul>
  <li>what the <b>weather</b> can look like if we *decided* to go play or not. (P(weather/decison))</li>
  <li>the <b>day type</b> depending of the state of <b>decision</b>. (P(day type/decison))</li>
  <li>the <b>wind level</b> knowing our *decision*. P(wind/decison)</li>
</ul>
As we already explained that they are independant we can juste merge these information together to take each one as an valid information for the decision. 

<br />
P(weather & day type & wind level/decison) = P(weather/decison) * P(day type/decison) * P(wind/decison)
<br />

<br />
The last useful information is the rate of our decision that is important too. Do we often go to play or not. This information is important as it is the one that influences all the others. (P(decison)).
<br/>
Well then. We have all we need to decide in the future knowing the informations around.<br/>

<br />
P(decison/weather & day type & wind level) = P(decison) * P(weather & day type & wind level/decison) 
<br />

That will give us a proportion that we can normalize to have probabilities. <b>The decision</b> that has the biggest probability will be the one we keep.

<br/>
<b>SUMMARY: NAIVE BAYES MAIN FORMULA IS:</b>
<br/>

P(Y/X) = P(Y) * $\prod$ P(X/Y) 

<br/>
<br/>
<b>NB: THE MOST USED IS THE LOG FORM:</b>
<br/>
P(Y/X) = log(P(Y))  + $\sum$ log(P(X/Y))
<br/>


<br/>
<br/>

<h3> <b> INSTALLATION </b> <h3>

<br/>

<h5><b> 1- GITHUB <b> </h5>
<br/>

The packages we propose is available via github directly. To install it please use these command bellow.
<br/>

NB: First you need to install *devtools* if you don't have it: 
<b>*install.packages("devtools")*</b>
</br>
</br>
If every thing is installed now you can copy paste this line to install it in your R:
</br>
*`devtools::install_github("Yameogo123/naive_bayes_classifier") `*

</br>
</br>

<h5><b> 2- tar-gz file <b> </h5>
<br/>
If the command is not working you can get the tar.gz file in our drive https://drive.google.com/drive/folders/1YzSpeBE9Ix5Kz9YWZIPRUfdgmeksKCQw directly. </br>
Download it and then import it in Rstudio manually in the packages onglet on your right.

<br/>

After installing it you can consume it with <br/>
*`library("naivebayesclassifier") `*


<br/>
<br/>

<h3> <b> USAGE </b> <h3>
<br/>

Let's dig into the class:
<ul>
   <li>
      <b>Documentation</b>:
      <ul>
         <li>
            We have integrated data on which you can test the packages functionnality: <br/>
            We have <b>patients</b> and <b>students</b> dataframes (tibble type).
            You can see the documentation with (example): <br/>
            <img width="464" alt="Screenshot 2023-12-05 at 14 33 40" src="https://github.com/Yameogo123/naive_bayes_classifier/assets/58187516/e90e55a0-1aa5-46c6-8ddd-eda792fc9f71">
         </li>
         <li>
            You can also see the documentation of the naive bayes class with the same syntax as: <b>?naive_bayes_classifier</b><br/>
            <img width="464" alt="Screenshot 2023-12-05 at 14 33 48" src="https://github.com/Yameogo123/naive_bayes_classifier/assets/58187516/d222b43e-78c0-442a-a03c-a6cda722e862"><br/>
         </li>
      </ul>
   </li>
   <li>
      <b>TEST</b>:<br/><br/>
      After a quick look of the documentation you will se the main functions we use from the packages to test the naives bayes algorithmes with parameters you need to know about.<br/>
      <ul>
         <li>
            First thing first after loading your package, initialize an object with it as:
            <br/>
            <img width="724" alt="Screenshot 2023-12-05 at 14 29 01" src="https://github.com/Yameogo123/naive_bayes_classifier/assets/58187516/4d5a7781-2b15-490e-a3ff-03ae5da77674"><br/><br/>
            NB: <br/>
            - type gives the type of naive bayes to use and can be one of (default, gaussian, bernoulli, multinomial)<br/>
            - discretize can be NULL, all (to discretize everything), non-gaussian (to discretize non-gaussian columns: that will use shapiro to test)<br/>
            - smoothness is between 0 (excluded) and 1 (or more but it's not a good idea) and will help us avoid 0 probabilities problems.<br/><br/>
         </li>
         <li>
            We will use our students data.<br/> <font color=red>!!PLEASE CONVERT THE DATA TO DATAFRAME BEFORE USING IT (IT IS TIBBLE AND SOMETIME IT BEHAVE DIFFERENTLY!!</font><br/><br/>
            Then on train students data that we apply the fit function<br/><br/>
            <img width="523" alt="Screenshot 2023-12-05 at 14 29 43" src="https://github.com/Yameogo123/naive_bayes_classifier/assets/58187516/08f219bc-b6cf-4d7e-b872-8f7b54e78cb2">
            <br/><br/>
            NB: <br/>
            - Sometimes you can see warning under in red. Don't mind them it just giving you information about how much columns have been discretised and another message that inform you that depending of you dataframe size the discretization can take supplementary seconds.(or minutes)<br/>
            - You must pass the Xtrain as first argument and the ytrain as second. Xtrain is a dataframe or matrix type and his number of row must be the same as the length of ytrain that is a vector containing the classes corresponding to Xtrain.<br/>
            <br/><br/>
         </li>
         <li>
            Then you can call the binding functions to see the details of the object<br/>
            <img width="520" alt="Screenshot 2023-12-05 at 14 31 31" src="https://github.com/Yameogo123/naive_bayes_classifier/assets/58187516/834c6183-6318-409e-873a-8d7018f9b79b"><br/><br/>
         </li>
         <li>
            You can see the summary of the object that will give you all the weights (probabilities).<br/>
            warning: summary will be as long as there are informations in your dataframe. <br/>
             <img width="523" alt="Screenshot 2023-12-05 at 14 30 15" src="https://github.com/Yameogo123/naive_bayes_classifier/assets/58187516/5df8619a-5ec1-4bea-b497-713dc357fc7a">
            <img width="523" alt="Screenshot 2023-12-05 at 14 30 33" src="https://github.com/Yameogo123/naive_bayes_classifier/assets/58187516/7e474c39-c96b-4b80-b91e-7d9b6e6bc856">
            <img width="870" alt="Screenshot 2023-12-05 at 14 30 52" src="https://github.com/Yameogo123/naive_bayes_classifier/assets/58187516/9550d910-7d07-43ca-a10f-5170c9abf1d0"><br/><br/>
         </li>
         <li>
            Let's do the probabilities prediction on the test data set<br/>
            <img width="591" alt="Screenshot 2023-12-05 at 14 31 46" src="https://github.com/Yameogo123/naive_bayes_classifier/assets/58187516/3774c1fc-ab61-4541-9c19-5f9d377d43a0"><br/><br/> 
            NB: <br/>
            Xtest must be a dataframe with the same columns as the train one. *predict* function works the same but will predict the classes of each Xtest rows and return a factor<br/><br/>
         </li>
         <li>
            Let's evalute the performance of our classification<br/>
             <img width="591" alt="Screenshot 2023-12-05 at 14 32 02" src="https://github.com/Yameogo123/naive_bayes_classifier/assets/58187516/c162ea4e-da5e-4c79-8a22-c21acd1fe651"><br/><br/>
            NB: <br/>
            - takes 2 upon 3 arguments. either (xtest and ytrue) or (ypred and ytrue). ytrue would be in our case ytest and ypred is the prediction on xtest. <br/>
            - One more argument of evaluate is positive_class. As we can see in our evaluate results, it takes No as target class. But we can put yes instead. That's where positive_class comes.  <br/>
            - <font color=red>Obviously it's a really bad accuracy because we use a lot of different variable to show that it's possible</font><br/><br/>
         </li>
      </ul>
   </li>
   <li>
      <b>OTHER</b>:<br/><br/>
      Others functions and arguments are possible with the class. Please read the doumentation on your Rstudio to see more. <br/>
   </li>
   
</ul>


<br/>
<br/>

<h3> <b> UI with R-shiny to test the code </b> </h3>

<h5><b> 1- Our RSHINY APP <b> </h5>
  
https://naivebayesclassfier.shinyapps.io/myapp/ <br/>

<br/>

<h5><b> 2- THE APP USAGE <b> </h5>

- Page 'La fonction': (describe R6 attributes and methods)<br/>
<img width="1291" alt="Screenshot 2023-12-05 at 14 44 10" src="https://github.com/Yameogo123/naive_bayes_classifier/assets/58187516/6b3e159a-89a1-48a4-8822-a937998916b1">

<br/><br/>

- Page 'Exemple' (will display an explained exemple of each algorithm of naive bayes)<br/>

<img width="1291" alt="Screenshot 2023-12-05 at 14 44 15" src="https://github.com/Yameogo123/naive_bayes_classifier/assets/58187516/50450971-de90-437b-ae57-a56173b3aa4a">


- Page 'Calcul': (click on 'Tables' tab: you will be able to load data and see table)<br/>
<img width="1291" alt="Screenshot 2023-12-05 at 14 44 35" src="https://github.com/Yameogo123/naive_bayes_classifier/assets/58187516/33d3a583-e36d-462f-84f6-2ec5b6d9b518">

<br/><br/>

- Page 'Calcul': (click on 'Graphiques' tab: you will be able to display data you just loaded before)<br/>
<img width="1291" alt="Screenshot 2023-12-05 at 14 44 40" src="https://github.com/Yameogo123/naive_bayes_classifier/assets/58187516/9b1971d0-e7f0-407f-9524-f4197fad03f2">
<br/><br/>


- Page 'Calcul' (click on Prediction' tab: you will see the predictions on top and just after you will see the conditionnal probabilities of these predictions.)<br/>
Here if you didn't set a test data it will make the prediction on the train data. <br/>
So that means you  can ignore test data and only work with train.<br/> 
<img width="1291" alt="Screenshot 2023-12-05 at 14 44 47" src="https://github.com/Yameogo123/naive_bayes_classifier/assets/58187516/d3d4bb24-7283-4d3f-9224-dd528e205bde">


<br/>
<br/>



<h3> <b> DOCUMENTATION </b> <h3>
<br/>

- Naive Bayes algorithms: <br/>
    https://rdrr.io/cran/naivebayes/api/ (r packages source) <br/>
    https://github.com/scikit-learn/scikit-learn/blob/main/sklearn/naive_bayes.py (python class source) <br/>
    https://www.youtube.com/watch?v=yRzIyWVEaCQ <br/>
    http://gnpalencia.org/optbinning/mdlp.html <br/>
    https://nlp.stanford.edu/IR-book/html/htmledition/the-bernoulli-model-1.html <br/>
    https://www.youtube.com/watch?v=km2LoOpdB3A <br/>
    https://tutoriels-data-science.blogspot.com/p/tutoriels-en-francais.html <br/>
    https://scikit-learn.org/stable/modules/naive_bayes.html <br/><br/>

- Rshiny:<br/>
    https://rstudio.github.io/shinythemes/  <br/>
    https://mastering-shiny.org/ <br />
    https://shiny.posit.co/r/articles/build/action-buttons <br />
    https://campus.datacamp.com/courses/building-web-applications-with-shiny-in-r/get-started-with-shiny?ex=1 <br/><br/>
    
- Package R (R6 class) <br/>
   https://campus.datacamp.com/courses/creating-r-packages/the-r-package-structure?ex=6 <br/>
   https://app.datacamp.com/learn/courses/object-oriented-programming-with-s3-and-r6-in-r <br/>
   https://tinyheero.github.io/jekyll/update/2015/07/26/making-your-first-R-package.html <br/>
   https://r-pkgs.org/vignettes.html  <br/><br/>                       
   

- Latex : (https://www.overleaf.com) <br/><br/>

- Parallel: <br/>
    https://cran.r-project.org/web/packages/doParallel/vignettes/gettingstartedParallel.pdf <br/>
    https://cran.r-project.org/web/packages/foreach/vignettes/foreach.html <br/><br/>
    
- Discretisation: https://eric.univ-lyon2.fr/ricco/tanagra/fichiers/fr_Tanagra_Discretization_Arbre.pdf <br/><br/>

- reduction: <br/>
    https://cran.r-project.org/web/packages/FactoMineR/index.html <br/>
    https://www.rdocumentation.org/packages/factoextra/versions/1.0.7/topics/fviz_famd <br/><br/>
   
  


<br/>
<br/>
<br/>











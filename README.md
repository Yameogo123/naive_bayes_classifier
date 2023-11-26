


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
*`devtools::github_install("Yameogo123/naive_bayes_classifier") `*

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
            <img width="580" alt="St" src="https://github.com/Yameogo123/naive_bayes/assets/58187516/72995cd3-404a-4ec5-b60e-02f0a0701dcc">.<br/>
            That will return something like: <br/>
            <img width="510" alt="Students" src="https://github.com/Yameogo123/naive_bayes/assets/58187516/956feb8b-9e30-4d1b-bd96-9ff89b05fedf"><br/>
         </li>
         <li>
            You can also see the documentation of the naive bayes class with the same syntax as: <b>?naive_bayes_classifier</b><br/>
            <img width="510" alt="Screenshot 2023-11-26 at 13 36 04" src="https://github.com/Yameogo123/naive_bayes/assets/58187516/2ae4670e-78f9-41d9-bbc3-b1b6099567b0"><br/>
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
            <img width="755" alt="Screenshot 2023-11-26 at 13 51 20" src="https://github.com/Yameogo123/naive_bayes/assets/58187516/25b82aeb-510b-4c41-bdce-0d78314a6dfc"><br/><br/>
            NB: <br/>
            - type gives the type of naive bayes to use and can be one of (default, gaussian, bernoulli, multinomial)<br/>
            - discretize can be NULL, all (to discretize everything), non-gaussian (to discretize non-gaussian columns: that will use shapiro to test)<br/>
            - smoothness is between 0 (excluded) and 1 (or more but it's not a good idea) and will help us avoid 0 probabilities problems.<br/><br/>
         </li>
         <li>
            We will use our patients data.<br/> <font color=red>!!PLEASE CONVERT THE DATA TO DATAFRAME BEFORE USING IT (IT IS TIBBLE AND SOMETIME IT BEHAVE DIFFERENTLY!!</font><br/><br/>
            <img width="829" alt="Screenshot 2023-11-26 at 14 09 48" src="https://github.com/Yameogo123/naive_bayes/assets/58187516/99ae6589-ae36-46a6-b386-4a656b855a2e"><br/><br/>
            Then on train patients data that we apply the fit function<br/><br/>
            <img width="843" alt="Screenshot 2023-11-26 at 14 13 02" src="https://github.com/Yameogo123/naive_bayes/assets/58187516/940be98a-d3e6-4f7d-a766-b4ac0c38808d"><br/><br/>
            NB: <br/>
            - You can see warning under in red. Don't mind them it just giving you information about how much columns have been discretised and another message that inform you that depending of you dataframe size the discretization can take supplementary seconds.(or minutes)<br/>
            - You must pass the Xtrain as first argument and the ytrain as second. Xtrain is a dataframe or matrix type and his number of row must be the same as the length of ytrain that is a vector containing the classes corresponding to Xtrain.<br/>
            <br/><br/>
         </li>
         <li>
            Then you can call the binding functions to see the details of the object<br/>
            <img width="843" alt="Screenshot 2023-11-26 at 14 24 04" src="https://github.com/Yameogo123/naive_bayes/assets/58187516/2d5a941f-78e0-4d8f-a098-2910461300d7"><br/><br/>
         </li>
         <li>
            You can see the summary of the object that will give you all the weights (probabilities).<br/>
            warning: summary will be as long as there are informations in your dataframe. <br/>
            <img width="512" alt="Screenshot 2023-11-26 at 14 27 50" src="https://github.com/Yameogo123/naive_bayes/assets/58187516/a6aad900-f2b3-4293-ba6a-14483c97917f"><br/><br/>
         </li>
         <li>
            Let's do the probabilities prediction on the test data set<br/>
            <img width="683" alt="Screenshot 2023-11-26 at 14 30 27" src="https://github.com/Yameogo123/naive_bayes/assets/58187516/d031b7bd-a7a0-4017-9268-3d0708524f76"><br/><br/> 
            NB: <br/>
            Xtest must be a dataframe with the same columns as the train one. *predict* function works the same but will predict the classes of each Xtest rows and return a factor<br/><br/>
         </li>
         <li>
            Let's evalute the performance of our classification<br/>
            <img width="683" alt="Screenshot 2023-11-26 at 14 35 53" src="https://github.com/Yameogo123/naive_bayes/assets/58187516/4b2b2135-5fcd-4cc1-b2ce-1055cacf815e"><br/><br/>
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

<h5><b> 1- LOAD FILE <b> </h5>



<br/>

<h5><b> 2- DISPLAY PLOTS <b> </h5>

- Page 'La fonction': (describe R6 attributes and methods)
<img width="964" alt="im2" src="https://github.com/Yameogo123/naive_bayes/assets/58187516/90a46aee-47a1-4108-8720-d18061d1751f">

- Page 'Calcul': (click on 'Tables' tab: you will be able to load data and see table)
<img width="962" alt="image" src="https://github.com/Yameogo123/naive_bayes/assets/58187516/e70be4f5-37fc-4e8d-b30e-6b5d799df33b">
<br/><br/>

- Page 'Calcul': (click on 'Graphiques' tab: you will be able to display data you just loaded before)
![shiny_data](https://github.com/Yameogo123/naive_bayes/assets/58187516/1b372b68-48eb-4e0f-90be-a13695663edc)
<br/><br/>

![shiny_data2](https://github.com/Yameogo123/naive_bayes/assets/58187516/2a154008-4a1e-4dca-b83c-331caff8aa10)
<br/><br/>


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

- Parallel: 
    https://cran.r-project.org/web/packages/doParallel/vignettes/gettingstartedParallel.pdf <br/>             
    https://cran.r-project.org/web/packages/foreach/vignettes/foreach.html <br/><br/>
    
- Discretisation: https://eric.univ-lyon2.fr/ricco/tanagra/fichiers/fr_Tanagra_Discretization_Arbre.pdf <br/><br/>

- reduction: 
    https://cran.r-project.org/web/packages/FactoMineR/index.html <br/>
    https://www.rdocumentation.org/packages/factoextra/versions/1.0.7/topics/fviz_famd <br/><br/>
   
  


<br/>
<br/>
<br/>











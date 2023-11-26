


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
Naive Bayes will respond to that question by supposing that there is no link between these information. I mean it's not because it is the weekend that there is a wind. So these informatives variables are not related. <br/>
But each of them have an impact on <b>the decision</b> so we can know the 
<ul>
  <li>what the <b>weather</b> can look like if we *decided* to go play or not. (P(weather/decison))</li>
  <li>the <b>day type</b> depending of the state of <b>decision</b>. (P(day type/decison))</li>
  <li>the <b>wind level</b> knowing our *decision*. P(wind/decison)</li>
</ul>
As we already explained that they are independant we can juste merge these information together to take each one as an valid information for the decision. 
$$
P(weather & day type & wind level/decison) = P(weather/decison)*P(day type/decison)*P(wind/decison)
$$

<br />
The last useful information is the rate of our decision that is important too. Do we often go to play or not. This information is important as it is the one that influences all the others. (P(decison)).
<br/>
Well then. We have all we need to decide in the future knowing the informations around.<br/>

$$
P(decison/weather & day type & wind level) = P(decison)*P(weather & day type & wind level/decison) 
$$

That will give us a proportion that we can normalize to have probabilities. <b>The decision</b> that has the biggest probability will be the one we keep.

<br/>
<b>SUMMARY: NAIVE BAYES MAIN FORMULA IS:</b>
<br/>
$P(Y/X) = P(Y)*\prod_{}{}P(X/Y)$

<br/>
<b>NB: THE MOST USED IS THE LOG FORM:</b>
<br/>
$P(Y/X) = log(P(Y))  + \sum_{}{}log(P(X/Y))$
<br/>


<br/>
<br/>

<h3> <b> INSTALLATION </b> <h3>

<br/>

<h5><b> 1- GITHUB <b> </h5>
<br/>

The packages we propose is available via github directly. To install it please use these command bellow.
<br/>

NB: First you need to install *devtools* if you don't have it: <b>*install.packages("devtools")*</b>
</br>
If every thing is installed now you can copy paste this line to install it in your R:
</br>
*`devtools::github_install("Yameogo123/naive_bayes_classifier") `*


<h5><b> 2- tar-gz file <b> </h5>
<br/>
If the command is not working you can get the tar.gz file in our drive https://drive.google.com/drive/folders/1YzSpeBE9Ix5Kz9YWZIPRUfdgmeksKCQw directly. Download it and then import it in Rstudio manually in the packages onglet on your right.

<br/>

After installing it you can consume it with <br/>
*`library("naivebayesclassifier") `*


<br/>
<br/>

<h3> <b> USAGE </b> <h3>




<h3> <b> UI with R-shiny to test the code </b> </h3>

<h5><b> 2- LOAD FILE <b> </h5>



<br/>

<h5><b> 2- DISPLAY PLOTS <b> </h5>

- Example 1:
![shiny_data](https://github.com/Yameogo123/naive_bayes/assets/58187516/1b372b68-48eb-4e0f-90be-a13695663edc)

- Example 1 (bottom)
![shiny_data2](https://github.com/Yameogo123/naive_bayes/assets/58187516/2a154008-4a1e-4dca-b83c-331caff8aa10)


<br/>
<br/>
<br/>











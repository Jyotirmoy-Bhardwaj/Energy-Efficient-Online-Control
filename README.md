
# time-ahead-estimation-RNN
<p align=justify>
This is a classical **prediction problem** solved by the Recurrent Neural Networks assisted by dropouts. One of the key challenges in any Machine Learning (ML) driven-control formulation is the estimation of some of the independent variables. In major applications of ML (such as Autonomous cars, real-time image processing, industrial control, etc.), the user is expected to perform time-ahead estimation of some of the key independent variables. One such example is the time-ahead estimation of independent variables such as dynamic energy price  {π<sub>t</sub>} and expected user water demand {d<sub>t</sub>}. In this work, we present a code; which can potentially estimate/predict the time-ahead expected water demand given the historical data. 

  
  *An example of a Water Distribution Network [a. Estimated Vs Actual] [b. Training Loss]:
<p float="left">
  <img src="docs/_images/Estimated_q_Flekkerøya.png" width="250" /> 
  <img src="docs/_images/MAE_Flekkerøya.png" width="250" />
</p>

# Requirements:
- [`TensorFlow`](https://www.tensorflow.org/)
- [`Keras`](https://keras.io/)
- [`numpy`](https://numpy.org/devdocs/)
- [`matplotlib`](https://matplotlib.org/)
- [`pandas`](https://pandas.pydata.org/)
- [`jupyter`](https://jupyter.org/)

## Installation
This framework is suitable for Python >= 3.7 environment. In addition, the historical time series data is obtained from the designed IoT infrastructure; which is not demonstrated in this repository.


## License
The project is licensed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html).


## Funding
This work was funded by:

<img align="middle" src="docs/_images/wisenet.PNG" width="150"> [Wisenet Research Center (UiA)](https://wisenet.uia.no/) 
<img align="middle" src="docs/_images/_02_NIVA_transparent_stor (2).png" width="100"> Norsk institutt for vannforskning (https://www.niva.no/) 

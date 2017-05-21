import AudioProc as AP
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.neural_network import MLPClassifier
import matplotlib.pyplot as plt
import numpy as np
from sklearn.cross_validation import train_test_split
from sklearn.metrics import roc_auc_score
from sklearn.metrics import confusion_matrix
from sklearn.linear_model import LogisticRegression

def TrainModel(fname, clf, previous = 0, window = 50, step = 50):
    # get the audio
    c = AP.InstrumentNoise()
    c.GetAudio(fname, 0, 160)
    # Add features
    c.CalBER(window, step, frel = [1210], freu = [1240],Enhance = False, AddFeature = True)
    c.CalFCC(window, step, AddFeature = True)
    c.CalFlatness(window, step, AddFeature = True,Enhance = False)
    c.CalHEF(window, step, AddFeature = True) 
    c.PrepareLabelDataFrame(test_size = 0.4)
    for i in range(10):
        clf = c.SupervisedTrain(clf)
    c.SupervisedPredict(clf)
    c.UpdateLabelDataFrame([60,65], 0)#update the condition
    if previous == 0:
        previous = c.Features
    else:
        np.concatenate((previous, self.Feature,), axis=0)
    return previous

#clf = c.SupervisedTrain(clf)
#c.SupervisedPredict(clf)
#c.VisualizeSupervisedLearning(window, step,speed = 0.01)
    

clf = RandomForestClassifier()
clf = MLPClassifier(solver='lbfgs', alpha=1e-3,hidden_layer_sizes=(8), random_state=1,max_iter=200) #8 for condition mornitoring
clf.warm_start=True # Evolving the previous model with new data
filename = 'Fan_Noise_Combine.wav'
TrainModel(filename, clf)
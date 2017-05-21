import AudioProc as AP
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.neural_network import MLPClassifier
import matplotlib.pyplot as plt
import numpy as np
from sklearn.cross_validation import train_test_split
from sklearn.metrics import roc_auc_score
from sklearn.metrics import confusion_matrix
from sklearn.linear_model import LogisticRegression

def smooth(data):
    data = data[:-10] + data[1:-9] + data[2:-8] + data[3:-7] + data[4:-6] + data[5:-5] + data[6:-4] + data[7:-3] + data[8:-2] + data[9:-1] + data[10:]
    return data / 10.0

def TrainModel(fname, clf, previous = 0, window = 50, step = 50):
    # get the audio
    c = AP.InstrumentNoise()
    c.GetAudio(fname, 0, 30)
    # Add features
    c.CalBER(window, step, frel = [1210], freu = [1240],Enhance = False, AddFeature = True)
    c.CalBER(window, step, frel = [100], freu = [400],Enhance = False, AddFeature = True)
    c.CalBER(window, step, frel = [3000], freu = [8000],Enhance = False, AddFeature = True)
    c.CalFCC(window, step, AddFeature = True)
    c.CalFlatness(window, step, AddFeature = True,Enhance = False)
    c.CalHEF(window, step, AddFeature = True)
    #plt.plot(smooth(c.Flatness[:150]))
    #plt.ylabel('Frequency Flatness')
    #plt.xlabel('Sample')
    #plt.savefig('Frequency Flatness',dpi = 600)
    #plt.show()
    return c.Feature

#clf = MLPClassifier(solver='lbfgs', alpha=1e-3,hidden_layer_sizes=(6), random_state=1,max_iter=200)
clf = GradientBoostingClassifier()
filename = 'Corroded bearing Fin Fan 150 rpm.wav'
Feature1 = TrainModel(filename, clf)
Label1 = np.ones(len(Feature1)) * 0
filename = 'Ouuter race bearing fault fin fan 150 rpm copy.wav'
Feature2 = TrainModel(filename, clf)
Label2 = np.ones(len(Feature2)) * 1
filename = 'Health Fan.wav'
Feature3 = TrainModel(filename, clf)
Label3 = np.ones(len(Feature3)) * 2

Features = np.concatenate((Feature1, Feature2, Feature3), axis = 0)
Label = np.concatenate((Label1, Label2, Label3), axis = 0)
X_train, X_test, y_train, y_test = train_test_split(Features, Label, test_size=0.3, random_state=0)
clf.fit(X_train, y_train)
print clf.score(X_test, y_test)
print confusion_matrix(y_test, clf.predict(X_test))
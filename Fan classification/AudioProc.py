# -*- coding: utf-8 -*-
"""
Created on Wed May 17 20:42:20 2017

@author: 21644336
"""

import wavio
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.cross_validation import train_test_split
from scipy.signal import butter, lfilter
from sklearn.preprocessing import normalize
from sklearn.metrics import confusion_matrix


class InstrumentNoise():
    def __init__(self):
        self.filename = ''
        sns.set_style("white")
    
    def GetAudio(self, filename, start = 0, end = 0.1):
        """Obtain the certain time section audio data from the origin wav file.
        Parameters
        ----------
        filename: origin audio file
        start : float, start time of the wanted audio signal.
        end : float, end time of the wanted audio signal.
        """
        if self.filename != filename:
            self.filename = filename
            self.df = wavio.read(filename)
        self.start = start
        self.end = end
        self.rate = self.df.rate
        self.data = self.df.data[int(self.start * self.df.rate) : int(self.end * self.df.rate)]
        
    def CutFrame(self, data, window, step):
        """cut the data into multiple frames
        
        * Parameters:
            data: the data you want to cut into frame, the total length may change depends on
                  the window, step and data length
            window: the quantity of samples contain in a frame (ms)
            step: the sample time different between two adjacent frame (ms)
        * Example:
            newframe = self.CutFrame(df, 10, 5) #window length is 10 ms, step is 5 ms
        * Return:
            return the data frame in matrix style, each row is one frame
        """
        
        frame = []
        for i in range(int(len(data)/(step*self.rate/1000.0)) - window/step+1):
            frame.append(data[i*step*self.rate/1000:(i*step+window)*self.rate/1000])
        frame = np.array(frame)
        return frame
    
    def ExportCsv(self,filename):
        """export the post-processing data as csv file, set the minimum data to 0
        * Parameters:
            filename: the export time
        * Example:
            a.ExportWav('export')
        * Return:
            return nothing, just output the csv data file
        """
        temp = pd.DataFrame(self.data)
        temp.columns = ['Sample_Rate_' + str(self.rate)]
        temp.to_csv(filename+'.csv',index = None)
            
    def butter_pass(self, cutoff, btype, order):
        """create the zero and polar of the filter, use the butter filter in this function
          more filters will be added later
        
        * Parameters:
            cutoff: the frequency limit, for bandpass filter, the parameter length must be 2
            btype: choose the type of the filter
                   high: for high pass
                   low: for low pass filter
                   band: for band pass filter
            order: the order of the filter, higher the order is, sharper the filter is
        * Example:
            b, a = self.butter_pass([20,800], 'band', order=10) #create the coefficient of bandpass filter between 20 Hz to 800 Hz
        * Return:
            return the coefficient for filter
        """
        
        nyq = 0.5 * self.rate
        normal_cutoff = np.array(cutoff) / nyq
        if len(normal_cutoff) == 2:
            normal_cutoff = list(normal_cutoff)
        return butter(order, normal_cutoff, btype=btype, analog=False)

    def butter_pass_filter(self, cutoff, btype, order=10, inplace = False):
        """apply the filter to the self.data
        
        * Parameters:
            cutoff: the frequency limit, for bandpass filter, the parameter length must be 2
            btype: choose the type of the filter
                   "high": for high pass
                   "low": for low pass filter
                   "bandpass": for band pass filter
                   "bandstop": for band stop filter
            order: the order of the filter, higher the order is, sharper the filter is. the default value is 10
            inplace: use the filtered data as the self.data
        * Example:
            a.butter_pass_filter([20,800], "band", order=10, inplace = True)
        * Return:
            return the filtered data
        """

        b, a = self.butter_pass(cutoff, btype, order=order)
        filtereddata = lfilter(b, a, self.data.ravel())
        if inplace:
            self.data = filtereddata
        return filtereddata            

    def checkmatrix(self, df):
        """Convert the unusable data to 0
        """
        df[df == np.inf] = 0
        df[df == -np.inf] = 0
        df[df == np.nan] = 0
        df[df == -np.nan] = 0
        return df

    def CalBER(self, window = 30, step = 10, frel = [3000], freu = [3000], Enhance = True, batch = 20, AddFeature = False):
        """Band Energy Ratio
        """
        data = self.data.ravel()
        column = int(len(data)/(step*self.rate/1000.0)) - window/step+1
        rownum = len(frel)
        self.BER = np.zeros([column,rownum])
        freup = self.rate/2.0
        for i in range(0,column,batch):
            temp = []
            for k in range(i,i+min([batch,column - i])):
			    temp.append(data[k*step*self.rate/1000:(k*step+window)*self.rate/1000])
            temp = np.array(temp)
            if np.abs(temp).sum():
                Spectrum = (abs(np.fft.rfft(temp) / float(temp.shape[1])) ** 2)
                SpeShape = Spectrum.shape[1]
                SpeSum = np.sqrt(np.sum(Spectrum,axis = 1))
                for j in range(rownum):
                    temp = Spectrum[:,int(frel[j] * SpeShape / freup):int(freu[j] * SpeShape / freup)+1]
                    self.BER[i:k+1,j] = np.sqrt(np.sum(temp, axis = 1)) / SpeSum
            else:
			    self.BER[i:k+1,:] = 0
        if AddFeature:
            try:
                self.Feature = np.concatenate((self.Feature,self.BER.reshape(-1,1)), axis=1)
            except:
                self.Feature = self.BER.reshape(-1,1)
        return self.BER
        
    def CalFlatness(self, window = 30, step = 10, Enhance = True, batch = 20, AddFeature = False):
        """Flatness
        """
        data = self.data.ravel()
        column = int(len(data)/(step*self.rate / 1000.0)) - window/step + 1
        self.Flatness = np.zeros(column)
        if Enhance:
            AdjustNoiseSpectrum = np.interp(np.linspace(0,self.rate,window*self.rate/1000/2+1),np.linspace(0,self.rate,len(self.NoiseSpectrum)),self.NoiseSpectrum)
        else:
            AdjustNoiseSpectrum = np.ones(2000 * window / 1000)
        for i in range(0,column,batch):
            temp = []
            for k in range(i,i+min([batch,column - i])):
                temp.append(data[k*step*self.rate/1000:(k*step+window)*self.rate/1000])
            temp = np.array(temp)
            Spectrum = abs(np.fft.rfft(temp) / float(temp.shape[1]))[:,:2000 * window / 1000] / AdjustNoiseSpectrum[:2000 * window / 1000]
            self.Flatness[i:k+1] = np.exp(np.mean(np.log(Spectrum),axis = 1)) / np.mean(Spectrum,axis = 1)
        if AddFeature:
            try:
                self.Feature = np.concatenate((self.Feature,self.Flatness.reshape(-1,1)), axis=1)
            except:
                self.Feature = self.Flatness.reshape(-1,1)
        return self.Flatness
    
    def CalHEF(self, window = 50, step = 25, frel=100, AddFeature = False):
        """Highest Energy Frequency
        """
        data = self.data.ravel()
        frame = self.CutFrame(data, window, step)
        SpectrumFrame = abs(np.fft.rfft(frame) / float(frame.shape[1]))
        start = frel * SpectrumFrame.shape[1] / (self.rate/2.0)
        self.HEF = np.argmax(SpectrumFrame[:,start:],axis = 1) + start
        self.HEF = self.HEF* (self.rate/2.0) / SpectrumFrame.shape[1]
        if AddFeature:
            try:
                self.Feature = np.concatenate((self.Feature,self.HEF.reshape(-1,1)), axis=1)
            except:
                self.Feature = self.HEF.reshape(-1,1)
        return self.HEF 
    
    def CalFCC(self, window = 50, step = 25, frel = 100, freu = 3000, AddFeature = False):
        """Frequency Centroid Centre
        """
        data = self.data.ravel()
        frame = self.CutFrame(data, window, step)
        SpectrumFrame = abs(np.fft.rfft(frame) / float(frame.shape[1])) ** 2
        fre = np.array([np.linspace(0, self.rate/2.0, SpectrumFrame.shape[1]),]*SpectrumFrame.shape[0]) 
        self.FCC = np.mean(SpectrumFrame[:,frel * SpectrumFrame.shape[1] / (self.rate/2.0):freu * SpectrumFrame.shape[1] / (self.rate/2.0)] * fre[:,frel * SpectrumFrame.shape[1] / (self.rate/2.0):freu * SpectrumFrame.shape[1] / (self.rate/2.0)],axis = 1) / np.mean(SpectrumFrame,axis = 1)
        if AddFeature:
            try:
                self.Feature = np.concatenate((self.Feature,self.FCC.reshape(-1,1)), axis=1)
            except:
                self.Feature = self.FCC.reshape(-1,1)
        return self.FCC
    
    def HOC(self, order = 2, visualize = False, window = 50, step = 25,batch = 10, AddFeature = False):
        """calculate the HOC in dataframe
        
        * Parameters:
            order: the order of the HOC 
            window: the quantity of samples contain in a frame (ms)
            visualize: visulize the result, default to be False
        * Example:
            Gate = self.HOC(order = 2, window = 10)
        * Return:
            return the HOC in array
        """
        data = self.data.ravel()
        for i in range(order):
            data = data[1:] - data[:-1]
        newdata = ((data[1:] * data[:-1]) < 0).astype(int)
        size = int(len(newdata)/(step*self.rate/1000.0)) - window/step+1
        self.HOC = np.zeros(size)
        for i in range(0,size,batch):
            temp = []
            for k in range(i,i+min([batch,size-i])):
                temp.append(newdata[k*step*self.rate/1000:(k*step+window)*self.rate/1000])
            self.HOC[i:k+1] = np.mean(temp,axis = 1)
            
        if AddFeature:
            try:
                self.Feature = np.concatenate((self.Feature,self.HOC.reshape(-1,1)), axis=1)
            except:
                self.Feature = self.HOC.reshape(-1,1)
        return self.HOC

    def PrepareLabelDataFrame(self, test_size = 0.5):
        """Convert the shrimp appearance time into label and make the label and 
        the origin frame into a dataframe.
        Parameters
        ----------
        filename: the file that contain the shrimp appearance time
        """
        self.label = np.zeros(len(self.Feature))
        self.label[:1201] = 0 # healthy
        self.label[1201:2401] = 1#unhealthy
        self.label[2401:] = -1#not working
        self.LabeledDF = np.concatenate((self.label.reshape(-1,1), self.Feature), axis=1)
        self.X_train, self.X_test, self.y_train, self.y_test = train_test_split(self.LabeledDF[:,1:], 
                                                                                self.LabeledDF[:,0], 
                                                                                test_size=test_size, 
                                                                                random_state=0)
    
    def UpdateLabelDataFrame(self, time, label, test_size = 0.5):
        self.label = np.zeros(len(self.Feature))
        self.label[:1201] = 0 # healthy
        self.label[1201:2401] = 1#unhealthy
        self.label[2401:] = -1#not working
        self.label[time[0] * 20:time[1] * 20] = label
        self.LabeledDF = np.concatenate((self.label.reshape(-1,1), self.Feature), axis=1)
        self.X_train, self.X_test, self.y_train, self.y_test = train_test_split(self.LabeledDF[:,1:], 
                                                                                self.LabeledDF[:,0], 
                                                                                test_size=test_size, 
                                                                                random_state=0)
    
    def SupervisedTrain(self, clf):
        """choose the model and use it to train the labeled data.
        Parameters
        ----------
        clf: sklearn model, the model you select for supervised learning
        """
        self.clf = clf
        self.clf.fit(normalize(self.X_train),self.y_train)
        print 'the classification accuracy is: {}'.format(self.clf.score(normalize(self.X_test),self.y_test))
        print confusion_matrix(self.y_test, self.clf.predict(normalize(self.X_test)))
        return self.clf
    
    def SupervisedPredict(self, clf):
        """A pipline to predict from raw data with the manofold model and
        classify model trained before.
        Parameters
        ----------
        manifold: model, manifold learning model.
        clf: model, classify model
        """
        self.prediction = clf.predict(pd.DataFrame(self.Feature))
        return self.prediction    

    """visualization part"""
    def VisualizationPresent(self, plt, animation, speed):
        """Present the figure plot before
        Parameters
        ----------
        plt: figure, the plot figure.
        animation: int, present in animation or statics.
        speed: float, the animination speed
        """
        if animation:
            plt.ion()
            plt.pause(speed)
            plt.close()
        else:
            plt.show()
            
    def VisualizeFrame(self,plt,minnum,maxnum,framelocation, color = 'r'):
        """Plot a frame on the signal with a window length
        Parameters
        ----------
        minnum: int, the upper bound of the frame.
        maxnum: int, the lower bound of the frame.
        step: the distance between each windows, must be smaller than windows and
        it decide the resolution of the sample with windows.
        framelocation: int, the start position of the frame
        plt: matplotlib figure, pass the figure here
        color: string, color for the frame
        """
        lw = 4
        plt.plot(self.rate * framelocation*np.array([self.step,self.step]) / 1000,[minnum,maxnum],c = color, linewidth=lw, linestyle='dashed')
        plt.plot(self.rate * (framelocation*np.array([self.step,self.step])+self.windows)/1000,[minnum,maxnum],c = color, linewidth=lw, linestyle='dashed')
        plt.plot(np.array([self.rate * framelocation*self.step / 1000,self.rate * (framelocation*self.step+self.windows) / 1000]),[maxnum,maxnum],c = color, linewidth=lw, linestyle='dashed')
        plt.plot(np.array([self.rate * framelocation*self.step / 1000,self.rate * (framelocation*self.step+self.windows) / 1000]),[minnum,minnum],c = color, linewidth=lw, linestyle='dashed')
    
        
    def VisualizeSupervisedLearning(self, window, step, animation = 1, speed = 0.01):
        """Visualize the result of supervised learning, if the frame color is green,
        that means the prediction is correct. but if it is red, it means the prediction
        is wrong. The frame and precision will be update in realtime
        ----------
        animation: bool, the switch of the figure presentation method. If it is
        on, the frame will continue to move forward while if it is off, the figure
        will present one by one manually.
        speed: the speed to play the animation
        """
        alldata = self.data / 10000.0
        loop = len(alldata)
        framelocation = 5
        color = ['b','g','r']
        resultlabel= ['not working','healthy','unhealthy']
        result = self.clf.predict(self.LabeledDF[:,1:]) + 1
        self.windows = window
        self.step = step
        Mymax = max(alldata)
        Mymin = min(alldata)
        for index in xrange(framelocation,loop):
            plt.figure(figsize=(16,8))
            data = alldata[self.rate * self.step*(index-framelocation) / 1000:self.rate *(self.step*(index-framelocation)+self.windows*10) / 1000]
            plt.plot(data, c = 'k')
            minnum = min(alldata[self.rate *self.step*(index)/ 1000:self.rate *(self.step*index+self.windows)/ 1000])*1.1
            maxnum = max(alldata[self.rate *self.step*(index)/ 1000:self.rate *(self.step*index+self.windows)/ 1000])*1.1
            temp = int(result[index])
            self.VisualizeFrame(plt, minnum,maxnum,framelocation, color[temp])
            plt.axis([0,self.rate * self.windows / 1000 * 10, Mymin,Mymax])
            plt.title(resultlabel[temp], fontsize = 20)
            self.VisualizationPresent(plt, animation, speed)
# DeepLearningTikTok
A tutorial for journalists to build deep learning models in order to monitor trends on TikTok

To read a more in-depth tutorial, check out my companion [blog post](https://jayge2017.medium.com/creating-a-deep-learning-model-to-track-trump-on-tiktok-5466ea503e34?sk=a77e003303c8a66b785edaabab85b3d9)

## Summary

TikTok has become a rising app and an important information source for journalists. Protests are organized on the platform--in June teens and K-Pop stans trended as they falsely registered for a Trump rally to artificially sell out the event. Live protest footage has also been recorded and shared on the app. In addition to political activity, the app has also been used by QAnon to spread conspiracy theories. When a conspiracy theory that Wayfair was selling children started to trend, Wayfair stock prices started to drop.

However despite the importance of the app, it’s notoriously hard to monitor. Unlike twitter and facebook, it’s primary media are videos. Though there are hashtags associated with each video, oftentime they are only loosely related to the topic of the video. In fact, many people add trending hashtags regardless of whether or not they relate to their video in the hopes of making it someone’s For You Page, essentially a user’s home feed of TikTok.

As such, I have created a tutorial for training a deep learning model to recognize a specific face on the app. (The face I have chosen is President Trump, however any face can be used. In fact, any image can be used. For example if you wanted to train the model to recognize confederate flags on the app, you can just swap the training data for images of confederate flags). This model is then used by a separate python script that will call a tiktok scraping api, and which can be run in the background of any computer, monitoring for potential appearances of Trump on the app. This will allow journalists to be alerted every time the president is trending on the app.

## Deep Learning
Deep Learning is a subfield of machine learning that relies on creating artificial neural networks to make predictions. It is incredibly powerful and is used in everything from auto-subtitling movies to powering self-driving cars. The structure of the neural networks also makes it especially good at recognizing complex features like faces in images. For this project, I chose Deep Learning to base my models off of because TikTok videos can be broken down into component images and these images can be used to train a powerful Deep Learning model. 

To learn more about deep learning n general visit here: https://machinelearningmastery.com/what-is-deep-learning/

The current two biggest libraries for deep learning are PyTorch and Tensorflow. While both have their advantages, Tensorflow is used for this project because I wanted to use colab to train my model (because of the free access to GPUs) and Tensorflow has better compatibility with colab. However in the future, if this project is to be improved on, PyTorch can also be used as a substitute. 

## Components of this project
This project has several files that work together, each detailed below. To run the project, download the model from the DeepLearning_Model_Tiktok.ipynb, then put it in a parallel directory to the run.sh script, then run that script via the command "sh run.sh".

### TikTok scraper
TikTok does not currently have an accessible api, and so an open-source scraper was used for this project. I choose to use tiktok-scraper by github user drawrowfly, but you are welcome to use any of the tiktok scrapers available to you, you only need to adjust that part in the shell script accordingly. This tiktok scraper also does not need a login, so you can be sure you are not scraping a custom trending page but rather the generic trending page for all users on the app.
Tiktok scraper used for project: https://github.com/drawrowfly/tiktok-scraper
### "Data_deeplearning"
This is a dataset of 700+ images and a csv that labels all the images. I personally hand-labeled these images from tiktok videos with Trump, random trending tiktok videos, and Google images. You will need to upload this to Google Drive first and then mount the colab notebook onto it.

### "DeepLearning_Tiktok.ipynb"
The model is created using a colab notebook. The jupyter notebook version of that has been uploaded to this repo under this file. To create the model, you should upload the Data_deeplearning repo into your google drive, then upload this notebook into google colab (which is free) and run the cells. This is because you will have access to free gpus, which will make the training much faster. This notebook will then output an h5 file of the finished, trained model which you will then download onto your local. The jupyter notebook contains text to walk you through training the model, and there are four general steps.

1. Labeling the data: For this project, our data are images that are captured from TikTok videos and some images from Google images. I chose to hand label captures from tiktok videos. This is because deep learning networks are very sensitive to features in the images, and because I was looking at creating a model for TikTok, I wanted mainly to train the model on TikTok specific images. (For example most of the time Trump appears on TikTok it is a recording of a television or computer screen, since rarely are people on TikTok posting first-hand accounts of seeing Trump). As such the label process is the most time consuming process in creating this model. I labeled 700+ images for this project by hand, and then supplemented them by using data augmentation (detailed in the jupyter notebook). If you would like to sub a different image for the model to recognize besides Trump, simply replace this step with images of the desired feature you wish to recognize and label accordingly. 

2. Running the images through a base model: In this project, I choose to run the images first through the VGG16 base model. VGG16 is a pre-trained model that takes in (224,224) RGB images and converts them into features. It comes out-of-the-box from the keras library and has been trained on millions of images from ImageNet. To read more about VGG16 model check out this site: https://neurohive.io/en/popular-networks/vgg16/

3. Training the model: We then create a sequential model with multiple Dense layers and dropout layers (to prevent overfitting). Using our data-augmented images, we train this sequential model. For this step, you only need to ensure that the input layer and output layer remain consistent as described in the notebook--the rest of the model you can customize as you see fit. 

4. Saving the model: We then save the model as an h5 file and download it to our local. You should then move the model to the same directory as this github repo. When you run your shell script, it will call the model and expect it to be in the same parallel directory.

### “run_model.py”
This python file is what generates the model’s prediction on the video. This file will load the pretrained model via the h5 file from the jupyter notebook, and then it will take an input video filename (which will be supplied by the shell script) and convert that video into images based on a capture frame rate of 5 frames/second. It will then run a prediction on each of those images, first by feeding the image through the VGG16 model from the keras library to extract features, and then running those features through our pretrained model. If there are any 1 labels predicted, we output that Trump has been spotted in a video. Currently, it is just a print statement however to connect it to an email alert is reasonably easy, simply have the output of the function call the email alert api.

### “run.sh”
This is a shell script that calls all the other necessary function (to kick everything off you only need to run this script). It first calls the TikTok api to retrieve the number 1 trending video on tiktok, downloads it into a directory called trends, then feeds that file name to run_model.py to make a prediction off of. It’s fairly simple and is only meant to show how the flow should look like. To make it run continuously is also relatively easy--you can just wrap it in a while loop, or you can schedule it to run at a certain time every day via a cron job. 

To run this, you might have to run “chmod +x run.sh” first on the file to make it executable. 

### "Biden.mp4"
This is an example tiktok video featuring only Biden and no Trump that you can use as a negative example.

### "Trump.mp4"
This is an example tiktok video featuring only Trump that you can use as a positive example.

## Future work
Currently, the major weaknesses of this project is that the TikTok scraper is not always reliable, most likely because TikTok itself has implemented anti-scraping measures on its app. As such you need to sometimes run the run.sh script multiple times before a trending video will download. However because that part is relatively isolated from the rest of the project, it can be easily replaced or improved on without a major overhaul of the whole design of the project. 

Another limitation is that this model can really only be trained to recognize one specific thing, such as one person’s face or one specific symbol. As such if you wanted it to recognize, for example, a few different presidential candidates, you would need to relabel all the images and redesign the model, since the output layer would need to have bigger dimensions to accommodate the additional labels. 

I also found that the model had trouble distinguishing between parodies of Trump (for example when someone dresses up like Trump and pretends to move like him) and actual videos of trump. It also did not pick up on any drawings of Trump (for example, if a TikTok user drew a cartoon of Trump and had it talk or move throughout the video, the model did not pick up on this). If a journalist would like all of these cases to be picked up by the model as recognizing Trump, they need only to add more examples of such cases in the training data. For example, if you want drawings of Trump to be picked up by the model, you need to add images with drawings of Trump labeled as having Trump in them in the training data. If you do not want parodies of Trump to be picked up by the model as a positive label, you need to add videos that have parodies of Trump and explicitly label them as a negative label. In this way you can ensure against these specific “close” cases that might throw off your model.

In the future, to improve upon these designs, more data should be used in training. Currently this project uses 700+ images, however to create a really accurate model you would need several, several times that amount. In addition, new designs can be explored for the models, such as adding more layers in the model and changing the number of neurons in each layer. The training process can also be edited--for example increasing or decreasing the epochs. I adjusted this value so that the model did not overfit the data, however you might find that adjusting the variable one more time may produce better results. 


### Acknowledgments
This project was based on this online tutorial: https://www.analyticsvidhya.com/blog/2018/09/deep-learning-video-classification-python/
Thank you to the author Pulkit Sharma for their work!

And thank you for visiting my page!


<a href="https://www.buymeacoffee.com/jayge2017" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-blue.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

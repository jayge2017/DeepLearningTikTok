tiktok-scraper trend -n 1 -d && \
filename=$(ls trend) && \
echo $filename &&\
python3 run_model.py trend/$filename &&\
rm -rf test_imgs && rm -rf trend


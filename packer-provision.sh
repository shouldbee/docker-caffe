sudo apt-get -y update
sudo apt-get install -y python-pip python-dev

# docker
sudo wget -qO- https://get.docker.com/ | sh
sudo usermod -aG docker ubuntu

# imagemagick
sudo apt-get install -y imagemagick

# build caffe
cd /home/ubuntu/caffe
git pull
make all -j $(nproc)
echo 'export PYTHONPATH=/home/ubuntu/caffe/python:$PYTHONPATH' >> /home/ubuntu/.bashrc

# build pycaffe
cd /home/ubuntu/caffe/python
for li in $(cat requirements.txt); do sudo pip install --upgrade $li; done
cd /home/ubuntu/caffe
make pycaffe -j $(nproc)

# to dismiss "libdc1394 error: Failed to initialize libdc1394"
# http://stackoverflow.com/questions/12689304/ctypes-error-libdc1394-error-failed-to-initialize-libdc1394
sudo ln /dev/null /dev/raw1394

# my .vim
git clone https://github.com/t-hiroyoshi/.vim /home/ubuntu/.vim

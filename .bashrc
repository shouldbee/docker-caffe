PROJECT=shouldbee/caffe
PS1="\`if [ \$? = 0 ]; then echo \[\e[32m\]${PROJECT}\[\e[0m\]; else echo \[\e[31m\]${PROJECT}\[\e[0m\]; fi\`:\w$ "
cd /vagrant

chakram () {
  sudo docker run -it --rm --net host -v `pwd`:/wd -w /wd shouldbee/chakram "$@"
}

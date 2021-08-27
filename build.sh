# install git and go
sudo apt-get install git
sudo apt install golang-go

# get the latest release version of the repository
new_version=$(curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/AxiomSamarth/go-release-event/releases/latest | jq '.tag_name')
echo "New version after curl" $new_version

new_version=$(echo $new_version | xargs)
echo "New version after trim" $new_version

new_version=$(echo "github.com/AxiomSamarth/go-release-event" $new_version)
echo "New version final" $new_version

# clone the dependant repository
git clone https://github.com/AxiomSamarth/go-release-consume.git

# navigate to dependant repository
cd go-release-consume

git remote set-url origin https://.:${{ secrets.TOKEN }}@github.com/AxiomSamarth/go-release-consume
echo "github.com:\n- user: AxiomSamarth\n  oauth_token: ${{ secrets.TOKEN }}\n  protocol: https" > ~/.config/hub

old_version=$(cat go.mod | grep github.com/AxiomSamarth/go-release-event | xargs)

# update the go.mod file of dependant project to the latest release version of this project
git checkout -b update-dependencies
sed -i -- 's#'"$old_version"'#'"$new_version"'#g' go.mod

go mod vendor
go mod tidy

# configure github.com/AxiomSamarth/go-release-event

git config --global user.email deyagondsamarth@gmail.com
git config --global user.name AxiomSamarth

git add *
git commit -m "automated vendoring of latest release of go-release-event"
git push  --force --quiet https://AxiomSamarth:${{ secrets.TOKEN }}@github.com/AxiomSamarth/go-release-consume update-dependencies:update-dependencies

hub pull-request --base main --head update-dependencies -m "update release-event dependencies"
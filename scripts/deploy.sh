git config --global user.email "deploy@travis.org"
git config --global user.name "Travis CI Deployment Bot"

cd site
git init
git add .
git commit -m ":rocket: Deploy to Github Pages"
git push --force --quiet "https://iagml:${GITHUB_TOKEN}@github.com/iagml/iagml.github.io.git" master:master
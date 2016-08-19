# creat-repos.sh

## Description
Create and push to a new github repo from the command line. This will use the ssh interface for updates and it puts the repos under origin.

Grabs sensible defaults from the containing folder and `.gitconfig`.

I found Rob Wierzbowski's original code here: [https://gist.github.com/robwierzbowski/5430952/] (https://gist.github.com/robwierzbowski/5430952/)

## Usage
```
    mkdir _ReposName_
    cd _ReposName_
    creat-repos.sh # Reply to the prompts
```
Now start adding your files and performing normal git functions.

## Todo
- clean up the terminology
- I'm not happy with the initial setup of the script. I'll need to think about the next step but this works and that's a start.

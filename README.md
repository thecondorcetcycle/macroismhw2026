# Orientation
Hey, if you're feeling a bit overwhelmed, here are some instructions to help ensure you don't get lost :)

## Using **VSCode Live-Share**
For when we're working at the same time.
Make sure you have the **Live Share** extension installed on **VSCode**! Otherwise feel free to shoot me a message if you'd like a link and I'll put one in the chat. Otherwise I'm trying to keep my instance running for as long as possible to ensure an old link doesn't expire.

To use **Live Share**, once you've installed the extension, you can either press *join* and you can paste your existing link, or create a session. If you create a session, you'll likely get a pop-up asking you to open a port - make sure you accept, so that people can connect to you that way.

## Installing and using **Git** on **VSCode**
Skip me if you already have  **Git** installed.

If we're not using **Live Share** and you're working on your own, you can clone this git repo, and then push your changes.
You'll need to check you have the **Git** extension installed (though it usually is be default on **VSCode**). You'll also need **Git** installed on your computer and a an account.

For me winget on PowerShell is the quickest way to install this on Windows:

> `winget install --id Git.Git -e --source winget`


On MacOS, this is either done with Xcode command line tools, and then via terminal, you can do:

> `xcode-select --install`

Or, if you have **Homebrew**:

> `brew install git`

Then, you can restart **VScode** and sign in via your **GitHub** account. After that, go into your terminal console and type in:

1. > `git config --global user.name "Your Name"`

2. >`git config --global user.email "your-email@example.com"`

with your own credentials for your name and email. (Note, you may need to restart **VSCode** for it to recongise that you have **Git** installed.)

## Using **Git** (for the project, via the terminal)
You can also use the GUI within **VSCode** for this, but if you prefer working with commands, here is a little guide.

Once you have **Git** installed, open the folder where you'd like to have the project copied in. Note that that you only need to do this once. Then type into our **VSCode** terminal:

> `git clone https://github.com/thecondorcetcycle/macroismhw2026.git`

(...or, if you prefer to put the contents of the **GitHub** repo directly into a folder of your choice:

1. > `git init`

2. > `git remote add origin https://github.com/thecondorcetcycle/macroismhw2026.git`

3. > `git pull origin main`).

Finally, when you finished adding in all your changes (make sure to save!), do:

1. `git add .`, or `git add [filename]` if you just worked one file

2. > `git commit -m "[the changes you did]"`

4. > `git push` 

And, for the next time you want to work on the repo:

> `git pull`

## Using **LaTeX** in **VSCode**

To work with LaTeX in **VSCode**, you’ll need a couple of things set up first. Don’t worry, it’s fairly straightforward.

### What you need to install

1. **A LaTeX distribution** (this is what actually compiles your `.tex` files):
   - **Windows**: Install **MiKTeX** or **TeX Live**
   - **MacOS**: Install **MacTeX**

2. **LaTeX Workshop extension in VSCode**
   - Go to Extensions in VSCode  
   - Search for **LaTeX Workshop** and install it  

3. **Perl (usually already handled)**
   - Required for `latexmk` (the build tool we’re using)
   - On **Mac/Linux**, it’s usually already installed  
   - On **Windows**, it comes bundled with MiKTeX or can be installed via Strawberry Perl if needed  

---

### Building your document

Once everything is installed:

- Open your `.tex` file in VSCode  
- Press:

`Ctrl + Alt + B`

This will compile your document using `latexmk`.

If everything is set up correctly, your PDF should appear automatically.

---

### Cleaning auxiliary files

LaTeX generates a lot of extra files (`.aux`, `.log`, etc.). To clean these up:

`Ctrl + Alt + C`

This removes auxiliary files, including the `.log` file (which is useful for debugging, so only clear it when you’re done investigating errors).

---

### Navigating between PDF and code

A very useful feature:

- **Ctrl + Click on the PDF**  
→ jumps to the corresponding place in your `.tex` file

This makes editing much faster, especially for long documents.

---

### If something doesn’t work

- Make sure LaTeX is installed correctly  
- Restart VSCode after installation  
- Check the `.log` file for errors (before cleaning it!)  

---

That’s all you need to get started. Once it’s working, the workflow is quite smooth: edit → build → preview → repeat.
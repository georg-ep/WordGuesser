//
//  ContentView.swift
//  WordScrambler
//
//  Created by George Patterson on 10/02/2021.
//

/*
    
    Ways to create a list
 
    List {
        content...
    }
 
    List is different to form bevause it can create rows dynamically without needing a foreach List(0..<5) {content...}
 
    Access the iterator number from the foreach \($0)
 
    modifier for displaying different list styles .listStyle(...)
 
    Remember you can label sections Section(header: Text(...))
 
    let people = [...]
 
    List(people, \.self) { // \.self tells us id position of each name in array
        $0 returns the names of the people based on their id (position in array)
    }
 
 
 
    List { //this is exactly the same as the loop above but in different format
        ForEach(people, \.self) {
           $0 returns the same
        }
    }
 
 */


/*
 
    When xcode builds our app, it creates an app bundle and it allows the system to store all the files for our app in a single place.
 
    It's common to want to look in a bundle for a file that we placed there. We access these files with a URL which is an optional as it may or may not be there.
 
    URLs can store LOCATIONS OF FILES as well as web addresses. Accessed by:
 
    Bundle.main.url()
 
     if let fileURL = Bundle.main.url(forResource: "some-file", withExtension: "txt") {
         // we found the file in our bundle!
     }
 
    Once we have our file we can load it into a string below:
    
 
     if let fileContents = try? String(contentsOf: fileURL) {
         // we loaded the file into a string!
     }
        
    We use try because it it may throw an error, say if it cannot convert contents to string
 
 */


/*
    
    Working with strings
 
    Below converts a single string to an array of strings breaking it up where another string has been found
 
     let input = "a b c"
     let letters = input.components(separatedBy: " ")
 
    We can set to a random letter like so
    
    let letter = letters.randomElement() // this is an optional
 
    We can remove whitespace and new lines like so
    
    let trimmed = letter?.trimmingCharacters(in: .whitespacesAndNewlines)
    //remmeber that letter is an optional that's why it has a ? after it
 
 
    Checking for mispelled words
 
     let word = "swift" //word to check
     let checker = UITextChecker() //create an instance of our checker
    
     let range = NSRange(location: 0, length: word.utf16.count)
    //tell our checker how much of the string to check
    //this creates an obj-c string range as this checker is from old UIKit based on C
    //UTF16 is the char encoding, a way of storing letters in strings
    
    let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
    //ask our checker to tell us whether it found any misspellings
    //this returns another C string
    //no spelling mistake returns NSNotFound from C
    
    let allGood = misspelledRange.location == NSNotFound
    //compares our misspelled range with NSNotFound to check whether any misspellings found


 
 */

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        
        NavigationView {
            VStack {
                
                //We provide a trailing closure to the textfiled using onCommit
                //when the return key is pressed the closure is called
                
                TextField("Please enter a word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle") //creates an image for each row with the number of letters of the word
                    Text($0)
                }
            }
            .navigationBarItems(trailing: Button(action: startGame) {
                Text("Generate New Word")
            })
            .navigationBarTitle("Words in: \(rootWord)")
            .onAppear(perform: startGame) // runs a closure when the view is shown
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                    
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            wordError(title: "Cannot enter a letter", message: "Has to be a word")
            return
        }
        
        // exit if the remaining string is empty
        guard isOriginal(word: answer) else {
            wordError(title: "Word Already Used!", message: "Be more original")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "No such word", message: "This word doesn't exist")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognised", message: "This word has to be contained within the rootWord!")
            return
        }
        
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") { // load txt file from bundle
            if let startWords = try? String(contentsOf: startWordsURL) { //convert txt file to a VERY long string
                let allWords = startWords.components(separatedBy: "\n") //create a string array based on each string in a new line
                rootWord = allWords.randomElement() ?? "silkworm"
                //set the rootword to a random element, optional return silkworm
                return
            }
        }
        //This error will simply cause our app to crash and not run.
        //if the if lets don't work and we get no return
        //fatalError method called
        fatalError("Couldn't load start.txt from bundle")
    }
    
    //checks whether word has been used before
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    //checks whether or not the enetered word can be made of the rootword
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord //sets a temporary word to rootword
        
        /*
         loop over each letter of the user’s input word to see if that letter exists in our copy. If it does, we remove it from the copy (so it can’t be used twice), then continue. If we make it to the end of the user’s word successfully then the word is good, otherwise there’s a mistake and we return false.
         */
            for letter in word {
                if let pos = tempWord.firstIndex(of: letter) {
                    tempWord.remove(at: pos)
                } else {
                    return false
                }
            }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker() //creates checker instance
        let range = NSRange(location: 0, length: word.utf16.count)
        //creates a new NSRange
        
        let misspelledWord = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        //checks to see if any words misspelled
        
        return misspelledWord.location == NSNotFound
   
    }
    
    //function for setting alert content
    func wordError(title: String, message: String) {
        self.errorTitle = title
        self.errorMessage = message
        showingError = true
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

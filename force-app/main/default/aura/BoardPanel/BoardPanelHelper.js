({
    setupPlaceholders: function(component) {
        // Set up placeholders for a 6x6 grid
        var rowsList = [];
        var colsList = [];
        
        for (var i = 1; i <= 6; i++) {
            rowsList.push(i);
            colsList.push(i);
        }
        
        component.set("v.placeholderRows", rowsList);
        component.set("v.placeholderCols", colsList);
        component.set("v.columnClass", "slds-size_1-of-6");
    },
    
    initializeGame: function(component) {
        // Reset game state
        component.set("v.gameActive", true);
        component.set("v.gameOver", false);
        component.set("v.gameWon", false);
        component.set("v.remainingGuesses", 3);
        component.set("v.revealedTiles", []);
        
        // Create a new board with random words
        this.createBoard(component);
    },
    
    createBoard: function(component) {
        var boardSize = component.get("v.boardSize");
        var availableWords = component.get("v.availableWords");
        var board = [];
        
        // Select random words for the board (without duplicates)
        var wordCount = boardSize * boardSize;
        
        // Make sure we have enough words
        if (availableWords.length < wordCount) {
            // If not enough words, duplicate the array until we have enough
            var originalWords = availableWords.slice();
            while (availableWords.length < wordCount) {
                availableWords = availableWords.concat(originalWords);
            }
        }
        
        // Shuffle the words
        this.shuffleArray(availableWords);
        
        // Take just the words we need
        var selectedWords = availableWords.slice(0, wordCount);
        
        // Select one random word as the correct one
        var correctWordIndex = Math.floor(Math.random() * selectedWords.length);
        var correctWord = selectedWords[correctWordIndex];
        component.set("v.correctWord", correctWord);
        
        // Create the board with the words
        for (var i = 0; i < boardSize; i++) {
            var row = [];
            for (var j = 0; j < boardSize; j++) {
                var cellIndex = i * boardSize + j;
                row.push({
                    word: selectedWords[cellIndex],
                    revealed: false
                });
            }
            board.push(row);
        }
        
        component.set("v.board", board);
    },
    
    shuffleArray: function(array) {
        for (var i = array.length - 1; i > 0; i--) {
            var j = Math.floor(Math.random() * (i + 1));
            var temp = array[i];
            array[i] = array[j];
            array[j] = temp;
        }
        return array;
    },
    
    handleCorrectWord: function(component) {
        var remainingGuesses = component.get("v.remainingGuesses");
        var score = component.get("v.score");
        
        // Calculate score based on guesses left
        var pointsEarned = remainingGuesses * 10;
        score += pointsEarned;
        
        component.set("v.score", score);
        component.set("v.gameOver", true);
        component.set("v.gameWon", true);
        
        // Reveal all tiles
        this.revealAllTiles(component);
    },
    
    handleWrongGuess: function(component) {
        var remainingGuesses = component.get("v.remainingGuesses");
        remainingGuesses--;
        component.set("v.remainingGuesses", remainingGuesses);
        
        // Check if game is over (no more guesses)
        if (remainingGuesses <= 0) {
            component.set("v.gameOver", true);
            component.set("v.gameWon", false);
            
            // Reveal all tiles
            this.revealAllTiles(component);
        }
    },
    
    revealAllTiles: function(component) {
        var board = component.get("v.board");
        
        // Go through all tiles and reveal them
        for (var i = 0; i < board.length; i++) {
            for (var j = 0; j < board[i].length; j++) {
                board[i][j].revealed = true;
            }
        }
        
        component.set("v.board", board);
    }
})
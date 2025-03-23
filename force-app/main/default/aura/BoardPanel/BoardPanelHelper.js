({
    helperMethod : function() {

    },
    initializeBoard: function(component) {
        // Get the board size
        var size = component.get("v.boardSize");
        
        // If a game mode is selected, update the columnClass accordingly
        if (size === 3) {
            component.set("v.columnClass", "slds-size_1-of-3");
        } else if (size === 4) {
            component.set("v.columnClass", "slds-size_1-of-4");
        } else if (size === 6) {
            component.set("v.columnClass", "slds-size_1-of-6");
        }
        
        // Sample letters for demonstration
        var letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        
        // Create a 2D array for the board
        var board = [];
        for(var i = 0; i < size; i++) {
            var row = [];
            for(var j = 0; j < size; j++) {
                // Generate a random letter
                var randomIndex = Math.floor(Math.random() * letters.length);
                var letter = letters.charAt(randomIndex);
                
                // Create a cell object
                row.push({
                    letter: letter,
                    rowIndex: i,
                    colIndex: j,
                    selected: false,
                    selectionTimestamp: 0 // Add timestamp for tracking selection order
                });
            }
            board.push(row);
        }
        
        // Set the board attribute
        component.set("v.board", board);
    },
    
    toggleTileSelection: function(component, rowIndex, colIndex) {
        var board = component.get("v.board");
        var cell = board[rowIndex][colIndex];
        
        // Toggle selection state
        if (!cell.selected) {
            // If selecting a new tile, set timestamp
            cell.selected = true;
            cell.selectionTimestamp = Date.now();
        } else {
            // If deselecting, clear timestamp
            cell.selected = false;
            cell.selectionTimestamp = 0;
        }
        
        // Update the board
        component.set("v.board", board);
        
        // Update selected word display
        this.updateSelectedWord(component);
    },
    
    updateSelectedWord: function(component) {
        var board = component.get("v.board");
        var selectedTiles = [];
        
        // Collect all selected tiles
        for(var i = 0; i < board.length; i++) {
            for(var j = 0; j < board[i].length; j++) {
                if(board[i][j].selected) {
                    selectedTiles.push(board[i][j]);
                }
            }
        }
        
        // Sort tiles by selection timestamp
        selectedTiles.sort(function(a, b) {
            return a.selectionTimestamp - b.selectionTimestamp;
        });
        
        // Build the word from ordered tiles
        var selectedWord = "";
        for(var k = 0; k < selectedTiles.length; k++) {
            selectedWord += selectedTiles[k].letter;
        }
        
        component.set("v.selectedWord", selectedWord);
    },
    
    validateAndScoreWord: function(component) {
        var selectedWord = component.get("v.selectedWord");
        if(selectedWord.length < 3) {
            component.set("v.isWordTooShort", true);
            return;
        }
        
        // Check for duplicate words
        var submittedWords = component.get("v.submittedWords");
        var isDuplicate = false;
        
        for(var i = 0; i < submittedWords.length; i++) {
            if(submittedWords[i].text.toLowerCase() === selectedWord.toLowerCase()) {
                isDuplicate = true;
                break;
            }
        }
        
        if(isDuplicate) {
            // Show duplicate word error
            component.set("v.duplicateWordError", true);
            // Clear error after 2 seconds
            setTimeout($A.getCallback(function() {
                if(component.isValid()) {
                    component.set("v.duplicateWordError", false);
                }
            }), 2000);
            return;
        }
        
        // Calculate score based on word length
        var wordScore = selectedWord.length * 10;
        
        // Add to list of submitted words
        submittedWords.push({
            text: selectedWord,
            score: wordScore,
            timestamp: Date.now()
        });
        
        // Update total score
        var score = component.get("v.score");
        score += wordScore;
        
        // Update component attributes
        component.set("v.submittedWords", submittedWords);
        component.set("v.score", score);
        
        // Clear selections
        var board = component.get("v.board");
        for(var i = 0; i < board.length; i++) {
            for(var j = 0; j < board[i].length; j++) {
                board[i][j].selected = false;
                board[i][j].selectionTimestamp = 0; // Reset timestamp too
            }
        }
        component.set("v.board", board);
        component.set("v.selectedWord", "");
        component.set("v.isWordTooShort", true);
    },
    
    startGameTimer: function(component) {
        console.log('Starting game timer');
        
        // Clear any existing timer
        this.clearGameTimer(component);
        
        // Reset timer class and ensure gameActive is true
        component.set("v.timerClass", "slds-text-color_default");
        component.set("v.gameActive", true);
        
        // Use Function.bind to maintain correct 'this' context
        var self = this;
        
        // Set up timer with proper binding and logging
        var gameTimerId = window.setInterval(function() {
            // Wrap the callback in $A.getCallback to ensure it runs in Aura context
            $A.getCallback(function() {
                if (!component.isValid()) {
                    console.log('Component not valid, clearing timer');
                    window.clearInterval(gameTimerId);
                    return;
                }
                
                var timeRemaining = component.get("v.timeRemaining");
                console.log('Timer tick: ' + timeRemaining);
                timeRemaining--;
                
                // Update timer class when time is running low
                if (timeRemaining <= 10) {
                    component.set("v.timerClass", "slds-text-color_error");
                }
                
                component.set("v.timeRemaining", timeRemaining);
                
                if (timeRemaining <= 0) {
                    console.log('Time up! Game over.');
                    // Game over
                    component.set("v.gameActive", false);
                    self.clearGameTimer(component);
                    self.showGameOverMessage(component);
                }
            })();
        }, 1000);
        
        console.log('Timer started with ID: ' + gameTimerId);
        // Store timer ID for later cleanup
        component.set("v.gameTimerId", gameTimerId);
    },
    
    clearGameTimer: function(component) {
        var gameTimerId = component.get("v.gameTimerId");
        if (gameTimerId) {
            console.log('Clearing timer with ID: ' + gameTimerId);
            window.clearInterval(gameTimerId);
            component.set("v.gameTimerId", null);
        }
    },
    
    showGameOverMessage: function(component) {
        // Show game over toast and final score
        var score = component.get("v.score");
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent) {
            toastEvent.setParams({
                title: "Game Over!",
                message: "Your final score is: " + score,
                type: "info",
                duration: 5000
            });
            toastEvent.fire();
        }
    },
    
    startNewGame: function(component) {
        // Reset submitted words list
        component.set("v.submittedWords", []);
        component.set("v.duplicateWordError", false);
        
        // ...any other game reset logic...
    }
})
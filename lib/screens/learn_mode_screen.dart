import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/vocabulary.dart';

class LearnModeScreen extends StatefulWidget {
   const LearnModeScreen({super.key});

  @override
  State<LearnModeScreen> createState() => _LearnModeScreenState();
}

class _LearnModeScreenState extends State<LearnModeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _answerController = TextEditingController();
  
  List<Vocabulary> _vocabularies = [];
  int _currentIndex = 0;
  int _correctAnswers = 0;
  int _totalAnswers = 0;
  bool _isLoading = true;
  bool _showResult = false;
  bool _hasAnswered = false;
  String _userAnswer = '';
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _loadVocabularies();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _loadVocabularies() async {
    try {
      List<Vocabulary> vocabularies = await _firestoreService.getRandomVocabularies(limit: 10);
      
      if (vocabularies.isEmpty) {
        _showNoVocabulariesDialog();
        return;
      }

      setState(() {
        _vocabularies = vocabularies;
        _isLoading = false;
      });
    } catch (e) {
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Laden der Vokabeln: $e'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).pop();
      }
    }
  }

  void _showNoVocabulariesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Keine Vokabeln'),
          content: Text('Du hast noch keine Vokabeln erstellt. Füge zuerst einige Vokabeln hinzu!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _checkAnswer() {
    if (_answerController.text.trim().isEmpty) return;

    String userAnswer = _answerController.text.trim().toLowerCase();
    String correctAnswer = _vocabularies[_currentIndex].foreign.toLowerCase();
    
    setState(() {
      _userAnswer = _answerController.text.trim();
      _isCorrect = userAnswer == correctAnswer;
      _hasAnswered = true;
      _totalAnswers++;
      
      if (_isCorrect) {
        _correctAnswers++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _vocabularies.length - 1) {
      setState(() {
        _currentIndex++;
        _answerController.clear();
        _hasAnswered = false;
        _userAnswer = '';
        _isCorrect = false;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    setState(() {
      _showResult = true;
    });
  }

  void _restartQuiz() {
    setState(() {
      _currentIndex = 0;
      _correctAnswers = 0;
      _totalAnswers = 0;
      _showResult = false;
      _hasAnswered = false;
      _userAnswer = '';
      _isCorrect = false;
    });
    _answerController.clear();
    _loadVocabularies();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: AppBar(
          title: Text('Lernmodus', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue.shade600,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.blue.shade600),
              SizedBox(height: 16),
              Text(
                'Lade Vokabeln...',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    if (_showResult) {
      return _buildResultScreen();
    }

    return _buildQuizScreen();
  }

  Widget _buildQuizScreen() {
    final vocabulary = _vocabularies[_currentIndex];
    double progress = (_currentIndex + 1) / _vocabularies.length;

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text('Lernmodus', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade600,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.blue.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress Info
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Frage ${_currentIndex + 1} von ${_vocabularies.length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  Text(
                    'Richtig: $_correctAnswers/$_totalAnswers',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Question Card
            Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.quiz,
                    size: 48,
                    color: Colors.blue.shade600,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Wie heisst auf ${vocabulary.language}:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    vocabulary.german,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Answer Input
            TextFormField(
              controller: _answerController,
              enabled: !_hasAnswered,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Deine Antwort eingeben...',
                prefixIcon: Icon(Icons.edit, color: Colors.blue.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onFieldSubmitted: (_) => _hasAnswered ? null : _checkAnswer(),
            ),
            SizedBox(height: 16),

            // Result Display
            if (_hasAnswered) ...[
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isCorrect ? Colors.green : Colors.red,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isCorrect ? Icons.check_circle : Icons.cancel,
                          color: _isCorrect ? Colors.green : Colors.red,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          _isCorrect ? 'Richtig!' : 'Falsch!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                    if (!_isCorrect) ...[
                      SizedBox(height: 8),
                      Text(
                        'Deine Antwort: $_userAnswer',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                      Text(
                        'Richtige Antwort: ${vocabulary.foreign}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 24),
            ],

            // Action Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _hasAnswered ? _nextQuestion : _checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasAnswered ? Colors.blue.shade600 : Colors.green.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _hasAnswered 
                      ? (_currentIndex < _vocabularies.length - 1 ? 'Nächste Frage' : 'Ergebnis anzeigen')
                      : 'Antwort prüfen',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    double percentage = _totalAnswers > 0 ? (_correctAnswers / _totalAnswers) * 100 : 0;

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text('Ergebnis', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade600,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          percentage >= 80 ? Icons.emoji_events : 
                          percentage >= 60 ? Icons.thumb_up : Icons.school,
                          size: 80,
                          color: percentage >= 80 ? Colors.amber : 
                                percentage >= 60 ? Colors.green : Colors.blue.shade600,
                        ),
                        SizedBox(height: 24),
                        Text(
                          percentage >= 80 ? 'Ausgezeichnet!' : 
                          percentage >= 60 ? 'Gut gemacht!' : 'Weiter üben!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '$_correctAnswers von $_totalAnswers richtig',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _restartQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Nochmal üben',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Zurück zur Übersicht',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
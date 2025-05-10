import 'package:flutter/material.dart';
import 'package:gif/gif.dart';

class ExerciseCard1 extends StatefulWidget {
  final String exerciseName;
  final String exerciseType;
  final int duration;
  final String description;
  final String gifFileName;

  ExerciseCard1({
    required this.exerciseName,
    required this.exerciseType,
    required this.duration,
    required this.description,
    required this.gifFileName,
  });

  @override
  _ExerciseCard1State createState() => _ExerciseCard1State();
}

class _ExerciseCard1State extends State<ExerciseCard1> with TickerProviderStateMixin {
  late GifController controller;

  @override
  void initState() {
    super.initState();
    controller = GifController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.repeat(min: 0, max: 48, period: Duration(milliseconds: 6000));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.exerciseName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(widget.exerciseName),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Durée : ${widget.duration} minutes'),
                              SizedBox(height: 8.0),
                              Text('Description : ${widget.description}'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Fermer'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            if (widget.gifFileName.isNotEmpty)
              Container(
                height: 50, // Ajustez la hauteur selon vos besoins
                child: Gif(
                  controller: controller,
                  image: AssetImage('assets/${widget.gifFileName}'),
                  fit: BoxFit.cover,
                ),
              )
            else
              Text("GIF non disponible", style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

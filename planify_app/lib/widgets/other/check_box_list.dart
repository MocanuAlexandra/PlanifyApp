import 'package:flutter/material.dart';

class CheckboxList extends StatefulWidget {
  final String title;
  final List<String> items;
  final List<String>? selectedItems;

  const CheckboxList(
      {Key? key,
      required this.items,
      required this.selectedItems,
      required this.title})
      : super(key: key);

  @override
  State<CheckboxList> createState() => _CheckboxListState();
}

class _CheckboxListState extends State<CheckboxList> {
  final ScrollController _controller = ScrollController();
  late List<String> _selectedItems;
  late String _title;

  @override
  void initState() {
    _title = widget.title;
    if (widget.selectedItems != null) {
      _selectedItems = widget.selectedItems!;
    } else {
      _selectedItems = [];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: SizedBox(
        height: 400.0,
        width: 300.0,
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(15.0),
              child: Text(
                _title,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Scrollbar(
                controller: _controller,
                thumbVisibility: true,
                thickness: 10,
                child: ListView.builder(
                  controller: _controller,
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      title: Text(widget.items[index]),
                      value: _selectedItems.contains(widget.items[index]),
                      onChanged: (value) {
                        if (value!) {
                          setState(() {
                            _selectedItems.add(widget.items[index]);
                          });
                        } else {
                          setState(() {
                            _selectedItems.remove(widget.items[index]);
                          });
                        }
                      },
                    );
                  },
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(_selectedItems);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(_selectedItems);
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

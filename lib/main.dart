import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final listaController = TextEditingController();

  void _addLista() {
    setState(() {
      Map<String, dynamic> novaTarefa = Map();
      novaTarefa["title"] = listaController.text;
      listaController.text = "";
      novaTarefa["ok"] = false;
      lista.add(novaTarefa);

      _saveData();
    });
  }

  List lista = [];
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;


  @override
  void initState(){
    super.initState();

    _readData().then((data){
      setState(() {
        lista = json.decode(data);
      });
    });
  }

  Future<Null> _refresh() async{ // função para atualizar a tela
    await Future.delayed(Duration(seconds: 1)); // vai esperar um segundona função

    setState(() {
      lista.sort((a, b){ // ordenar a lista
        if (a["ok"] && !b["ok"])
          return 1;
        else if(!a["ok"] && b["ok"])
          return -1;
        else return 0;
      });

      _saveData(); // salvar a lista ordenada
    });
    return null;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.yellow[500],
        title: Text(
          'Task List',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(5, 10, 5, 5),
            child: TextField(
              controller: listaController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Digite a Tarefa!",
                  labelStyle: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
          RaisedButton(
            color: Colors.black,
            child: Text("Done",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),
            onPressed: _addLista,
          ),
          Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                    padding: EdgeInsets.only(top: 10),
                    itemCount: lista.length,
                    itemBuilder: buildItem),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildItem(context, index){
      return Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        background: Container(
          color: Colors.red,
          child: Align(
            alignment: Alignment(-0.9,0.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
        direction: DismissDirection.startToEnd,
        child: CheckboxListTile(
          title: Text(lista[index]["title"]),
          value: lista[index]["ok"],
          secondary: CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(
                lista[index]["ok"] ? Icons.check : Icons.android
            ),
          ),
          onChanged: (c){
            setState(() {
              lista[index]["ok"] = c;
              _saveData();
            });
          },
        ),
        onDismissed: (direction){
          setState(() {
            _lastRemoved = Map.from(lista[index]);
            _lastRemovedPos = index;
            lista.removeAt(index);

            _saveData();

            final snack = SnackBar(content: Text("Tarefa \"${_lastRemoved["title"]}\" removida!"),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: (){
                setState(() {
                  lista.insert(_lastRemovedPos, _lastRemoved);
                  _saveData();
                });
              },
            ),
              duration: Duration(seconds: 3),
            );
            Scaffold.of(context).showSnackBar(snack);
          });
        },

      );
    }


  Future<File> _getFile() async {
    // função q retorna o arquivo pra salvar no dispositivo
    final directory =
        await getApplicationDocumentsDirectory(); // pega o diretorio no dispositivo para armazenas o map
    return File(
        "${directory.path}/data.json"); // retorna um arquivo e especifica o caminho, pega o caminho do diretorio e junta com o data.json
  }

  Future<File> _saveData() async {
    // função pra salvar os dados
    String data = json.encode(lista); // esta pegando a lista e transformando em json e salvando em uma string
    final file = await _getFile(); // pega o arquivo aonde ele vai salvar,
    return file.writeAsString(data); // ele vai escrever dentro do arquivo
  }

  Future<String> _readData() async {
    // função para ler os arquivos
    try {
      // tenta fazer algo se n conseguir retorna oque você colocar;
      final file = await _getFile(); // tenta pegar o arquivo
      return file.readAsString(); // tentar ler o arquivo como string;
    } catch (e) {
      return null;
    }
  }
}

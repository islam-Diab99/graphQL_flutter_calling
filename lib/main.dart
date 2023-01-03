import 'dart:io';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';



const productGraphQl="""
query products {
  products(channel: "default-channel", filter: {search: "hoodie"},first:10){
    edges{
      node{
        name
        id
        description
        thumbnail{
          url
        }
      }
    }
  }
}
    """ ;
void main() async {

final HttpLink httpLink =HttpLink('https://demo.saleor.io/graphql/');
ValueNotifier<GraphQLClient> client= ValueNotifier(
    GraphQLClient (link: httpLink,cache: GraphQLCache(store: InMemoryStore())));
var app=GraphQLProvider(client: client,child: const MyApp(),);
WidgetsFlutterBinding.ensureInitialized();
  runApp(app);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GraphQL Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'GraphQL Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),


      ),
      body: Center(
        child: Query(
          options:QueryOptions(
            document: gql(productGraphQl)
          ) ,

          builder: (QueryResult result, { VoidCallback? refetch, FetchMore? fetchMore }){
if(result.hasException){
  return Center(child: Text(result.exception.toString()));
}
if(result.isLoading){
  return const CircularProgressIndicator();
}
final List productList=result.data!['products']['edges'];
return
  GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 2.0,
          mainAxisSpacing: 2.0,
          childAspectRatio: .75
        ),
        itemCount: productList.length,
        itemBuilder: (_,index){
          var product=productList[index]['node'];
          return Column(
            children: [
              Image.network(product['thumbnail']['url']),
              Text(product['name'])
            ],
          );

        }
  );
          }
        ),
      ),

    );
  }


}
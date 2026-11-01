import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const TyreScanApp());

class TyreScanApp extends StatelessWidget {
  const TyreScanApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'THARINDU TYRE SCAN',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange), useMaterial3: true),
        home: const StockHome(),
      );
}

class TyreRecord {
  final String id, brand, size, serial, notes, sidewallPath, treadPath;
  final DateTime createdAt;
  TyreRecord({required this.id, required this.brand, required this.size, required this.serial, required this.notes, required this.sidewallPath, required this.treadPath, required this.createdAt});
  Map<String, dynamic> toJson() => {'id':id,'brand':brand,'size':size,'serial':serial,'notes':notes,'sidewallPath':sidewallPath,'treadPath':treadPath,'createdAt':createdAt.toIso8601String()};
  factory TyreRecord.fromJson(Map<String,dynamic> j) => TyreRecord(id:j['id'] ?? '',brand:j['brand'] ?? '',size:j['size'] ?? '',serial:j['serial'] ?? '',notes:j['notes'] ?? '',sidewallPath:j['sidewallPath'] ?? '',treadPath:j['treadPath'] ?? '',createdAt:DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now());
}

class StockHome extends StatefulWidget { const StockHome({super.key}); @override State<StockHome> createState()=>_StockHomeState(); }
class _StockHomeState extends State<StockHome> {
  final List<TyreRecord> records=[]; final search=TextEditingController(); bool loading=true;
  @override void initState(){super.initState(); _load();}
  Future<void> _load() async { final p=await SharedPreferences.getInstance(); final raw=p.getString('tyre_records') ?? '[]'; try { records.addAll((jsonDecode(raw) as List).map((e)=>TyreRecord.fromJson(e))); } catch (_) {} if(mounted)setState(()=>loading=false); }
  Future<void> _save() async { final p=await SharedPreferences.getInstance(); await p.setString('tyre_records',jsonEncode(records.map((e)=>e.toJson()).toList())); }
  Future<void> _add() async { final result=await Navigator.push<TyreRecord>(context,MaterialPageRoute(builder:(_)=>const AddTyrePage())); if(result!=null){setState(()=>records.insert(0,result));await _save();} }
  @override Widget build(BuildContext context){ final q=search.text.toLowerCase(); final shown=records.where((r)=>'${r.brand} ${r.size} ${r.serial} ${r.notes}'.toLowerCase().contains(q)).toList(); return Scaffold(appBar:AppBar(title:const Text('THARINDU TYRE SCAN'),),floatingActionButton:FloatingActionButton.extended(onPressed:_add,icon:const Icon(Icons.add_a_photo),label:const Text('Add Dag Tyre')),body:loading?const Center(child:CircularProgressIndicator()):Column(children:[Padding(padding:const EdgeInsets.all(12),child:TextField(controller:search,onChanged:(_)=>setState((){}),decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Brand / size / serial search',border:OutlineInputBorder()))),Expanded(child:shown.isEmpty?const Center(child:Text('No tyres saved yet. Tap “Add Dag Tyre”.')):ListView.builder(itemCount:shown.length,itemBuilder:(context,i){final r=shown[i];return Card(margin:const EdgeInsets.symmetric(horizontal:12,vertical:6),child:ListTile(leading:r.sidewallPath.isNotEmpty&&File(r.sidewallPath).existsSync()?Image.file(File(r.sidewallPath),width:58,height:58,fit:BoxFit.cover):const Icon(Icons.tire_repair,size:42),title:Text(r.brand.isEmpty?'Unknown brand':r.brand),subtitle:Text('Size: ${r.size.isEmpty?'—':r.size}\nSerial: ${r.serial.isEmpty?'—':r.serial}'),isThreeLine:true,onTap:()=>showDialog(context:context,builder:(_)=>AlertDialog(title:Text(r.brand.isEmpty?'Tyre record':r.brand),content:Text('Size: ${r.size}\nSerial: ${r.serial}\nNotes: ${r.notes}\n\nSaved locally on this device.')),)));})),]),); }
}

class AddTyrePage extends StatefulWidget { const AddTyrePage({super.key}); @override State<AddTyrePage> createState()=>_AddTyrePageState(); }
class _AddTyrePageState extends State<AddTyrePage>{
 final picker=ImagePicker(); final brand=TextEditingController(),size=TextEditingController(),serial=TextEditingController(),notes=TextEditingController(); String sidewall='',tread='';
 Future<void> _photo(bool isSidewall) async { final x=await picker.pickImage(source:ImageSource.camera,imageQuality:85); if(x!=null)setState(()=>isSidewall?sidewall=x.path:tread=x.path); }
 Widget _photoTile(String label,String path,VoidCallback action)=>Expanded(child:InkWell(onTap:action,child:Container(height:150,margin:const EdgeInsets.all(5),decoration:BoxDecoration(border:Border.all(color:Colors.grey),borderRadius:BorderRadius.circular(12)),child:path.isNotEmpty&&File(path).existsSync()?ClipRRect(borderRadius:BorderRadius.circular(12),child:Image.file(File(path),fit:BoxFit.cover,width:double.infinity)):Column(mainAxisAlignment:MainAxisAlignment.center,children:[const Icon(Icons.camera_alt,size:36),const SizedBox(height:8),Text(label,textAlign:TextAlign.center)]))));
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Add Dag Tyre')),body:ListView(padding:const EdgeInsets.all(16),children:[const Text('Take both tyre photos',style:TextStyle(fontWeight:FontWeight.bold)),Row(children:[_photoTile('Sidewall photo\n(brand / size / serial)',sidewall,()=>_photo(true)),_photoTile('Tread photo\n(tread condition)',tread,()=>_photo(false))]),const SizedBox(height:12),TextField(controller:brand,decoration:const InputDecoration(labelText:'Brand',border:OutlineInputBorder())),const SizedBox(height:10),TextField(controller:size,decoration:const InputDecoration(labelText:'Tyre size',hintText:'e.g. 185/65R15',border:OutlineInputBorder())),const SizedBox(height:10),TextField(controller:serial,decoration:const InputDecoration(labelText:'Serial / DOT code',border:OutlineInputBorder())),const SizedBox(height:10),TextField(controller:notes,maxLines:3,decoration:const InputDecoration(labelText:'Notes / condition',border:OutlineInputBorder())),const SizedBox(height:16),FilledButton.icon(onPressed:(){if(sidewall.isEmpty||tread.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Please take both sidewall and tread photos.')));return;}Navigator.pop(context,TyreRecord(id:DateTime.now().microsecondsSinceEpoch.toString(),brand:brand.text.trim(),size:size.text.trim(),serial:serial.text.trim(),notes:notes.text.trim(),sidewallPath:sidewall,treadPath:tread,createdAt:DateTime.now()));},icon:const Icon(Icons.save),label:const Text('Save to offline stock'))]));
}

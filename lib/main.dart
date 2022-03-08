import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
void main(){
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/MyPage',
    routes: {
       '/MyPage':(context)=>MyApp(),
      '/BigPic':(context)=>Scaffold(body: BigPic(),),

    },
  ));
}
class MyApp extends StatelessWidget{
  var SomeImg=MultiPicContainer(Icons.add_a_photo_outlined,"AddPic",8);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text("Multi_Image_Upload_Interface")),
      body: Center(
        child: Column(
          children: [
            SomeImg,
            SizedBox(height: 30,),
            TextButton(
              onPressed: (){
                ReallySimpleSnackBar(SomeImg.PicPathList.toString(), 1000, context);
              },
              child: Text("The path of these pictures is...",style: TextStyle(fontSize: 20),),
            ),
            SizedBox(height: 30,),
            TextButton(
              onPressed: (){
                ReallySimpleSnackBar(SomeImg.CurrentPicNum.toString(), 1000, context);
              },
              child: Text("The number of these pictures is...",style: TextStyle(fontSize: 20),)
            ),
          ],
        ),
      ),
    );
  }
}

class MultiPicContainer extends StatefulWidget{
  IconData icon;
  String HintText;
  Color color;
  double InternalSize;
  double Size;
  int CurrentPicNum=0;

  final MaxPicNum;

  List PicPathList=[];
  MultiPicContainer(
      this.icon,
      this.HintText,
      this.MaxPicNum,
      {
        this.color=Colors.lightBlue,
        this.InternalSize=15,
        this.Size=70,
      }
      );
  @override
  MultiPicContainerState createState()=>MultiPicContainerState();
}

class MultiPicContainerState extends State<MultiPicContainer> {

  List<Widget> PicListForUser=[];

  void _KillSelf({Widget? W}){
    widget.PicPathList.removeAt(PicListForUser.indexOf(W!));
    widget.CurrentPicNum--;
    setState(() {
      PicListForUser.remove(W);
      if(widget.CurrentPicNum==widget.MaxPicNum-1){
        PicListForUser.add(
            MyButton(widget.color,widget.InternalSize,widget.Size,widget.icon,
                widget.HintText,_AddPic)
        );
      }
    });
  }
  void _AddPic()async{
    if(widget.PicPathList.length<widget.MaxPicNum){
      String? ANewPath=null;
      var futureImg=await _PickImage();
      if(futureImg!=null){
        ANewPath=futureImg.path;
        setState(() {
          widget.CurrentPicNum++;
          PicListForUser.insert(PicListForUser.length-1,ImgWithDel(futureImg, _KillSelf));
          if(widget.CurrentPicNum>=widget.MaxPicNum){
            PicListForUser.removeAt(widget.MaxPicNum);
          }
        });
        widget.PicPathList.add(ANewPath);
      }
    }
  }

  @override
  void initState(){
    super.initState();
    setState(() {
      PicListForUser.add(
          MyButton(Colors.lightBlue,widget.InternalSize,widget.Size, widget.icon,
              widget.HintText,_AddPic)
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 10,
      children: PicListForUser,
    );
  }
}

class MyButton extends StatelessWidget{
  IconData iconPic;
  String text;
  Color hisColor;
  double hisSize;
  double outSize;
  void Function() onClick;
  MyButton(this.hisColor,this.hisSize,this.outSize,this.iconPic,this.text,this.onClick);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        width: this.outSize,
        height: this.outSize,
        //color: Colors.red,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconPic,
              color: hisColor,
              size: hisSize*3,
            ),
            SizedBox(height: 5,),
            Text(
              text,
              style: TextStyle(
                color: hisColor,
                fontSize: hisSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImgWithDel extends StatelessWidget{
  File ThisImage;
  void Function({Widget W}) f;

  ImgWithDel(this.ThisImage,this.f);
  @override
  Widget build(BuildContext context) {
    var that=this;
    return Container(
      height: 80,
      width: 80,
      child: Stack(
        children: [
          Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: (){
                  f(W: that);
                },
                child: Icon(
                  Icons.clear,
                  size: 25,
                ),
              )
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: GestureDetector(
              child: Hero(
                tag: ThisImage.path,
                child: Image.file(
                  ThisImage,
                  width: 55,
                  height: 55,
                ) ,
              ),
              onTap: (){
                Navigator.pushNamed(context, '/BigPic',arguments: ThisImage);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BigPic extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    File ThisImage=ModalRoute.of(context)!.settings.arguments as File;
    return Container(
      child: Hero(
        tag: ThisImage.path,
        child: Image.file(
          ThisImage,
          fit: BoxFit.cover,
        ),
      ),
      alignment: Alignment.center,
    );
  }
}
Future<File?> _PickImage() async{
  var img=await ImagePicker().pickImage(source: ImageSource.gallery);
  if(img==null)return null;
  final tmpImg=File(img.path);
  return tmpImg;
}

Future<File?> testCompressAndGetFile(File file, String targetPath) async {
  int Quality=30;
  var Extension=file.absolute.path.substring(file.absolute.path.lastIndexOf(".") + 1, (file.absolute.path).length);

  if(Extension!="jpg"&&Extension!="jpeg"){
    return file;
  }
  var result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path, targetPath,
    quality: Quality,
    //rotate: 180,
  );

  return result;
}

Future<List> CompressPicInList(List PicPathList)async{
  int i;
  for(i=0;i<=PicPathList.length-1;i++){
    String ANewPath=PicPathList[i];
    String CompressedPath=
        ANewPath.substring( 0, ANewPath.lastIndexOf("."))
            + "_tmp"
            +ANewPath.substring(ANewPath.lastIndexOf(".") , (ANewPath).length);

    var compressedResult=await testCompressAndGetFile(File(ANewPath), CompressedPath);
    if(compressedResult!=null){
      PicPathList[i]=CompressedPath;
    }
  }
  return PicPathList;
}

void ReallySimpleSnackBar(String str,int ms,BuildContext context){
  var snackBar=SnackBar(
    content: Text(str),
    duration: Duration(milliseconds: ms),
  );
  ScaffoldMessenger.of(context).showSnackBar((snackBar));
}

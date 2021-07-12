import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
part 'search_images_state.dart';


class SearchImagesCubit extends Cubit<SearchImagesState> {
  SearchImagesCubit() : super(SearchImagesInitial());

  void loadUrl(String url) async{
    try {
      final response = await http.get(url);
      dom.Document document = parse(response.body);
      final List<dynamic> imgList = document.querySelectorAll('img');
      emit(SearchImagesSuccess(imgList));
    }catch(e){
      emit(SearchImagesFail(e.toString()));
    }
  }
}

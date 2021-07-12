import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'download_images_state.dart';

class DownloadImagesCubit extends Cubit<DownloadImagesState> {
  DownloadImagesCubit() : super(DownloadImagesInitial());
}

part of 'search_images_cubit.dart';

abstract class SearchImagesState extends Equatable {
  const SearchImagesState();

  @override
  List<Object> get props => [];
}

class SearchImagesInitial extends SearchImagesState {}

class SearchImagesSuccess extends SearchImagesState {
  final List<dynamic> result;
  SearchImagesSuccess(this.result);

  @override
  List<Object> get props => [result];
}

class SearchImagesFail extends SearchImagesState {
  final String error;
  SearchImagesFail(this.error);

  @override
  List<Object> get props => [error];
}

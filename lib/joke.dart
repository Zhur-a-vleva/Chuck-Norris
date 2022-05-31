import 'package:json_annotation/json_annotation.dart';

part 'joke.g.dart';

@JsonSerializable()
class Joke {
  Joke(this.icon_url, this.id, this.url, this.value);

  String icon_url;
  String id;
  String url;
  String value;

  factory Joke.fromJson(Map<String, dynamic> json) => _$JokeFromJson(json);

}

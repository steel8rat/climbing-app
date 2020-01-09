import 'package:climbing/classes/my_location.dart';
import 'package:test/test.dart';

void main() {
  test("Location wrapper can be used to obtain gps coordinates", () async {
    MyLocation.getCoordinates().then((Coordinates coordinates) {
      expect(coordinates.latitude is double, true);
      expect(coordinates.longitude is double, true);
    });
  });
}
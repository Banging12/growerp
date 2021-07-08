import 'package:integration_test/integration_test.dart';
import 'newCompany_test.dart' as newCompany;
import 'category_test.dart' as category;
import 'product_test.dart' as product;
import 'asset_test.dart' as asset;
import 'opportunity_test.dart' as opportunity;

/// all integration tests can be ran independantly
/// They start with a new company create the items needed for the tes
/// and do the actual test
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  newCompany.main();
  category.main();
  product.main();
  asset.main();
  opportunity.main();
}

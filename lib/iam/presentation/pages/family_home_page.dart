import 'package:flutter/material.dart';

import '../../../family/presentation/pages/family_portal_page.dart';
import '../../../profiles/domain/entities/person_profile.dart';

class FamilyHomePage extends StatelessWidget {
  final PersonProfile? profile;

  const FamilyHomePage({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    return const FamilyPortalPage();
  }
}

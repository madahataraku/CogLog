// Placeholder until tool/generate_oss_licenses.sh runs.
// ignore_for_file: public_member_api_docs

class Package {
  const Package({
    required this.name,
    this.license,
  });

  final String name;
  final String? license;
}

const allDependencies = <Package>[];

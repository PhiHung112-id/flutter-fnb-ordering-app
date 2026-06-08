import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';
import '../utils/app_colors.dart';
import '../widgets/product_card.dart';

class SearchPage extends ConsumerStatefulWidget {
  SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  String searchText = '';
  String selectedType = 'Tất cả';
  String selectedSort = 'Mặc định';

  final searchController = TextEditingController();

  final typeFilters = const [
    'Tất cả',
    'Đồ ăn',
    'Đồ uống',
    'Bán chạy',
  ];

  final sortOptions = const [
    'Mặc định',
    'Giá thấp → cao',
    'Giá cao → thấp',
    'Đánh giá cao',
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> getFilteredProducts(
      List<Map<String, dynamic>> products,
      ) {
    var result = products.where((product) {
      final title = product['title']?.toString().toLowerCase() ?? '';
      final description =
          product['description']?.toString().toLowerCase() ?? '';
      final category = product['category']?.toString().toLowerCase() ?? '';
      final query = searchText.toLowerCase().trim();

      final matchesSearch = query.isEmpty ||
          title.contains(query) ||
          description.contains(query) ||
          category.contains(query);

      if (!matchesSearch) return false;

      if (selectedType == 'Đồ ăn') {
        return product['type'] == 'food';
      }

      if (selectedType == 'Đồ uống') {
        return product['type'] == 'drink';
      }

      if (selectedType == 'Bán chạy') {
        return product['isPopular'] == true;
      }

      return true;
    }).toList();

    if (selectedSort == 'Giá thấp → cao') {
      result.sort((a, b) {
        final priceA = (a['price'] as num?)?.toDouble() ?? 0;
        final priceB = (b['price'] as num?)?.toDouble() ?? 0;
        return priceA.compareTo(priceB);
      });
    }

    if (selectedSort == 'Giá cao → thấp') {
      result.sort((a, b) {
        final priceA = (a['price'] as num?)?.toDouble() ?? 0;
        final priceB = (b['price'] as num?)?.toDouble() ?? 0;
        return priceB.compareTo(priceA);
      });
    }

    if (selectedSort == 'Đánh giá cao') {
      result.sort((a, b) {
        final ratingA = (a['rating'] as num?)?.toDouble() ?? 0;
        final ratingB = (b['rating'] as num?)?.toDouble() ?? 0;
        return ratingB.compareTo(ratingA);
      });
    }

    return result;
  }

  void clearSearch() {
    FocusScope.of(context).unfocus();

    setState(() {
      searchText = '';
      selectedType = 'Tất cả';
      selectedSort = 'Mặc định';
      searchController.clear();
    });
  }

  void showSortBottomSheet() {
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card(context),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (bottomSheetContext) {
        final primary = Theme.of(context).colorScheme.primary;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border(context),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                SizedBox(height: 18),

                Text(
                  'Sắp xếp món',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary(context),
                  ),
                ),

                SizedBox(height: 14),

                ...sortOptions.map((option) {
                  final isSelected = selectedSort == option;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primary.withOpacity(0.18),
                          primary.withOpacity(0.08),
                        ],
                      )
                          : null,
                      color: isSelected ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? primary.withOpacity(0.26)
                            : Colors.transparent,
                      ),
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onTap: () {
                        setState(() {
                          selectedSort = option;
                        });

                        Navigator.pop(bottomSheetContext);
                      },
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? primary
                            : primary.withOpacity(
                          AppColors.isDark(context) ? 0.20 : 0.12,
                        ),
                        child: Icon(
                          isSelected ? Icons.check : Icons.sort,
                          color: isSelected ? Colors.white : primary,
                        ),
                      ),
                      title: Text(
                        option,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                        Icons.check_circle,
                        color: primary,
                      )
                          : null,
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final filteredProducts = getFilteredProducts(products);
    final primary = Theme.of(context).colorScheme.primary;

    final hasFilter = searchText.trim().isNotEmpty ||
        selectedType != 'Tất cả' ||
        selectedSort != 'Mặc định';

    return Scaffold(
      backgroundColor: AppColors.background(context),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        foregroundColor: AppColors.textPrimary(context),
        title: Text(
          'Tìm món',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (hasFilter)
            TextButton(
              onPressed: clearSearch,
              child: Text(
                'Xóa lọc',
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _SearchHeader(
            searchController: searchController,
            searchText: searchText,
            selectedType: selectedType,
            typeFilters: typeFilters,
            onSearchChanged: (value) {
              setState(() {
                searchText = value;
              });
            },
            onClearKeyword: () {
              setState(() {
                searchText = '';
                searchController.clear();
              });
            },
            onTypeSelected: (filter) {
              setState(() {
                selectedType = filter;
              });
            },
            onSortTap: showSortBottomSheet,
          ),

          Expanded(
            child: filteredProducts.isEmpty
                ? _EmptySearchResult(
              query: searchText,
              hasFilter: hasFilter,
              onReset: clearSearch,
            )
                : LayoutBuilder(
              builder: (context, constraints) {
                const horizontalPadding = 18.0;
                const spacing = 14.0;

                final itemWidth = (constraints.maxWidth -
                    horizontalPadding * 2 -
                    spacing) /
                    2;

                return SingleChildScrollView(
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${filteredProducts.length} món phù hợp',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textPrimary(context),
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ),

                          if (selectedSort != 'Mặc định')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: primary.withOpacity(
                                  AppColors.isDark(context) ? 0.20 : 0.12,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: primary.withOpacity(0.25),
                                ),
                              ),
                              child: Text(
                                selectedSort,
                                style: TextStyle(
                                  color: primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: 14),

                      Wrap(
                        spacing: spacing,
                        runSpacing: 14,
                        children: filteredProducts.map<Widget>((product) {
                          return SizedBox(
                            width: itemWidth,
                            child: ProductCard(product: product),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  final TextEditingController searchController;
  final String searchText;
  final String selectedType;
  final List<String> typeFilters;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearKeyword;
  final ValueChanged<String> onTypeSelected;
  final VoidCallback onSortTap;

  _SearchHeader({
    required this.searchController,
    required this.searchText,
    required this.selectedType,
    required this.typeFilters,
    required this.onSearchChanged,
    required this.onClearKeyword,
    required this.onTypeSelected,
    required this.onSortTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.border(context),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            textInputAction: TextInputAction.search,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'Tìm đồ ăn, đồ uống, combo...',
              hintStyle: TextStyle(
                color: AppColors.textSecondary(context),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: primary,
              ),
              suffixIcon: searchText.isNotEmpty
                  ? IconButton(
                onPressed: onClearKeyword,
                icon: Icon(
                  Icons.close,
                  color: AppColors.textSecondary(context),
                ),
              )
                  : null,
              filled: true,
              fillColor: AppColors.background(context),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: AppColors.border(context),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: primary.withOpacity(0.65),
                  width: 1.3,
                ),
              ),
            ),
          ),

          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    itemCount: typeFilters.length,
                    separatorBuilder: (_, __) => SizedBox(width: 9),
                    itemBuilder: (context, index) {
                      final filter = typeFilters[index];
                      final isSelected = selectedType == filter;

                      return InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () => onTypeSelected(filter),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 220),
                          padding: const EdgeInsets.symmetric(horizontal: 13),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? AppColors.primaryGradient(context)
                                : null,
                            color: isSelected ? null : AppColors.card(context),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isSelected
                                  ? primary
                                  : AppColors.border(context),
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: primary.withOpacity(0.18),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              filter,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary(context),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(width: 10),

              InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: onSortTap,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.border(context),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow(context),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tune,
                        size: 18,
                        color: primary,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Sắp xếp',
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptySearchResult extends StatelessWidget {
  final String query;
  final bool hasFilter;
  final VoidCallback onReset;

  _EmptySearchResult({
    required this.query,
    required this.hasFilter,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final keyword = query.trim();
    final primary = Theme.of(context).colorScheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 20,
            ),
            child: Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppColors.border(context),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow(context),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient(context),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.22),
                            blurRadius: 14,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.search_off_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),

                    SizedBox(height: 16),

                    Text(
                      'Không tìm thấy món phù hợp',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      keyword.isEmpty
                          ? 'Hiện chưa có món nào phù hợp với bộ lọc bạn chọn.'
                          : 'Không có sản phẩm nào trùng với "$keyword". Thử nhập từ khóa ngắn hơn hoặc đổi bộ lọc.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        height: 1.4,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: 16),

                    if (hasFilter)
                      ElevatedButton.icon(
                        onPressed: onReset,
                        icon: Icon(Icons.refresh_rounded),
                        label: Text('Xóa bộ lọc'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
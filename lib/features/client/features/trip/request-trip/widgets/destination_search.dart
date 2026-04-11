// destination_search.dart

import 'dart:async';

import 'package:auronix_app/app/theme/app_colors.dart';
import 'package:auronix_app/app/theme/theme_extensions.dart';
import 'package:auronix_app/features/client/features/trip/domain/models/interfaces/place_entity.dart';
import 'package:auronix_app/features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DestinationSearch extends StatefulWidget {
  const DestinationSearch({super.key});

  @override
  State<DestinationSearch> createState() => _DestinationSearchState();
}

class _DestinationSearchState extends State<DestinationSearch> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Cancelar búsqueda anterior
    _debounce?.cancel();

    if (query.isEmpty) {
      context.read<RequestTripBloc>().add(const ClearSearchEvent());
      return;
    }

    // Debounce: esperar 500ms antes de buscar
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<RequestTripBloc>().add(SearchDestinationEvent(query));
    });
  }

  void _onResultTap(PlaceEntity place) {
    _searchController.text = place.name;
    context.read<RequestTripBloc>().add(SelectDestinationEvent(place));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<RequestTripBloc, RequestTripState>(
      builder: (context, state) {
        return Column(
          children: [
            // Campo de búsqueda
            Container(
              decoration: BoxDecoration(
                color: AppColorsExtension.inputColor(context),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColorsExtension.borderColor(context),
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.isLight
                        ? AppShadowColors.thirdSoft
                        : AppShadowColors.darkSoft,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: '¿A dónde vas?',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColorsExtension.textSecondaryColor(context),
                  ),
                  prefixIcon: Icon(Icons.search, color: AppColors.third),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            context.read<RequestTripBloc>().add(
                              const ClearSearchEvent(),
                            );
                          },
                          icon: Icon(
                            Icons.close,
                            color: AppColorsExtension.textSecondaryColor(
                              context,
                            ),
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
              ),
            ),

            // Resultados de búsqueda
            if (state.searchResults.isNotEmpty) ...[
              8.verticalSpace,
              Container(
                constraints: BoxConstraints(maxHeight: 200.h),
                decoration: BoxDecoration(
                  color: AppColorsExtension.cardColor(context),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColorsExtension.borderColor(context),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.isLight
                          ? AppShadowColors.blackSoft
                          : AppShadowColors.darkSoft,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: state.searchResults.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: AppColorsExtension.borderColor(context),
                  ),
                  itemBuilder: (context, index) {
                    final result = state.searchResults[index];
                    return ListTile(
                      onTap: () => _onResultTap(result),
                      leading: Icon(Icons.location_on, color: AppColors.third),
                      title: Text(
                        result.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        result.address,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColorsExtension.textSecondaryColor(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 14.r,
                        color: AppColorsExtension.textSecondaryColor(context),
                      ),
                    );
                  },
                ),
              ),
            ],

            // Loading indicator
            if (state.isSearching)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(AppColors.third),
                ),
              ),

            // Error message
            if (state.errorMessage != null)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                  state.errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.sevent,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

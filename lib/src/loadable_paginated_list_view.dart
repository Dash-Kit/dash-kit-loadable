import 'package:flutter/material.dart';
import 'package:dash_kit_core/dash_kit_core.dart';
import 'package:dash_kit_loadable/src/loadable_list_view.dart';

class LoadablePaginatedListView<T extends StoreListItem>
    extends LoadableListView<T> {
  const LoadablePaginatedListView({
    Key key,
    @required LoadablePaginatedListViewModel<T> viewModel,
    ScrollPhysics scrollPhysics = const AlwaysScrollableScrollPhysics(),
    double cacheExtent,
    void Function(double offset) onChangeContentOffset,
  }) : super(
          key: key,
          viewModel: viewModel,
          scrollPhysics: scrollPhysics,
          onChangeContentOffset: onChangeContentOffset,
          cacheExtent: cacheExtent,
        );

  @override
  State<StatefulWidget> createState() {
    return LoadablePaginatedListState<T>();
  }
}

class LoadablePaginatedListState<T extends StoreListItem>
    extends LoadableListViewState<T> {
  @override
  LoadablePaginatedListViewModel<T> get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      final canLoad = (viewModel.paginatedList.loadPageRequestState.isSucceed ||
              viewModel.paginatedList.loadPageRequestState.isIdle) &&
          viewModel.paginatedList.isAllItemsLoaded == false;

      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          canLoad) {
        viewModel?.loadPage();
      }
    });
  }

  @override
  Widget buildListItem(BuildContext context, int index) {
    return index == viewModel.itemsCount - 1
        ? _getLastItem(
            viewModel.getPaginationState(),
          )
        : super.buildListItem(context, index);
  }

  Widget _getLastItem(PaginationState state) {
    switch (state) {
      case PaginationState.loadingPage:
        return _getProgressPageWidget(scrollController);

      case PaginationState.errorLoadingPage:
        return _getErrorPageWidget();

      default:
        return Container();
    }
  }

  Widget _getProgressPageWidget(ScrollController scrollController) {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 100),
              curve: Curves.linear,
            ));

    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(top: 8),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _getErrorPageWidget() {
    return viewModel.errorPageWidget ?? Container();
  }
}

class LoadablePaginatedListViewModel<Item extends StoreListItem>
    extends LoadableListViewModel<Item> {
  LoadablePaginatedListViewModel({
    Key key,
    @required Widget errorWidget,
    @required Widget emptyStateWidget,
    @required Widget Function(int) itemBuilder,
    @required this.paginatedList,
    @required this.errorPageWidget,
    VoidCallback loadList,
    EdgeInsets padding,
    Axis scrollDirection = Axis.vertical,
    Widget Function(int) itemSeparator,
    this.loadPage,
  })  : assert(paginatedList != null),
        super(
          items: paginatedList.items,
          loadListRequestState: paginatedList.loadListRequestState,
          itemBuilder: itemBuilder,
          loadList: loadList,
          errorWidget: errorWidget,
          emptyStateWidget: emptyStateWidget,
          padding: padding,
          key: key,
          itemSeparator: itemSeparator,
          scrollDirection: scrollDirection,
        );

  final VoidCallback loadPage;
  final PaginatedList<Item> paginatedList;
  final Widget errorPageWidget;

  @override
  int get itemsCount => super.itemsCount + 1;

  @override
  PaginationState getPaginationState() {
    final paginationState = super.getPaginationState();
    if (paginationState != PaginationState.idle) {
      return paginationState;
    }

    if (paginatedList.loadPageRequestState.isFailed) {
      return PaginationState.errorLoadingPage;
    } else if (paginatedList.loadPageRequestState.isInProgress) {
      return PaginationState.loadingPage;
    }

    return PaginationState.idle;
  }
}

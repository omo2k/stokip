import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stokip/feature/model/importer_model.dart';
import 'package:stokip/product/navigator_manager.dart';
import 'package:stokip/product/widgets/currency_popup_button.dart';

import '../../cubit/importers/importer_cubit.dart';
import '../../cubit/stock/stock_cubit.dart';
import '../purchases_view.dart';
import '../../../product/constants/enums/currency_enum.dart';
import '../../../product/constants/enums/images_enum.dart';
import '../../../product/image_picker_manager.dart';

class SuppliersView extends StatelessWidget with NavigatorManager {
  const SuppliersView({super.key});

  @override
  Widget build(BuildContext context) {
    final textEditingController = TextEditingController();
    final stockCubit = BlocProvider.of<StockCubit>(context);

    final importerCubit = BlocProvider.of<ImporterCubit>(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider<StockCubit>.value(
          value: stockCubit..updateAppBarTitle('Tacirler'),
        ),
        BlocProvider<ImporterCubit>.value(value: importerCubit),
      ],
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: BlocBuilder<StockCubit, StockState>(
            builder: (context, state) {
              return Text(
                state.appBarTitle!,
              );
            },
          ),
          actions: [
            BlocBuilder<ImporterCubit, ImporterState>(
              builder: (context, state) {
                return IconButton(
                  onPressed: () {
                    _showModal(context, titleController: textEditingController);
                  },
                  icon: Icon(Icons.add),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<ImporterCubit, ImporterState>(
          builder: (context, state) {
            return ListView.builder(
              itemCount: state.importers?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    navigateToPage(
                      context,
                      PurchasesView(
                        index: index,
                        importerState: state,
                        importerCubit: importerCubit,
                        stockCubit: stockCubit,
                      ),
                    );
                  },
                  child: ListTile(
                    leading: _ImporterLeading(
                      state,
                      index,
                    ),
                    title: Text(state.importers?[index].title ?? ''),
                    subtitle: Text(state.importers?[index].id.toString() ?? ''),
                    trailing: Text(
                      '${state.importers?[index].balance ?? 0} ${state.importers?[index].currency?.getSymbol}',
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ImporterLeading extends StatelessWidget {
  const _ImporterLeading(
    this.state,
    this.index,
  );
  final ImporterState state;
  final int index;

  CircleAvatar get _userAvatar {
    if (state.importers?[index].customerPhoto == null) {
      return CircleAvatar(
        backgroundImage: ImagesEnum.defaul.getImages(null),
      );
    } else {
      return CircleAvatar(
        backgroundImage: ImagesEnum.selected.getImages(state.importers?[index].customerPhoto),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final response = ImageUploadManager().fetchFromLibrary();
        context.read<ImporterCubit>().saveFileToLocale(await response, index);
      },
      child: _userAvatar,
    );
  }
}

void _showModal(
  BuildContext context, {
  TextEditingController? titleController,
}) {
  showModalBottomSheet<void>(
    context: context,
    builder: (_) {
      return BlocProvider<ImporterCubit>.value(
        value: BlocProvider.of<ImporterCubit>(context),
        child: Scaffold(
          body: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(hintText: 'Cari Adini giriniz'),
                        controller: titleController,
                        onEditingComplete: () {},
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: BlocBuilder<ImporterCubit, ImporterState>(
                          builder: (context, state) {
                            return CurrencyPopupButton<ImporterModel>(
                              importerState: state,
                            );
                          },
                        )),
                  ),
                ],
              ),
              BlocBuilder<ImporterCubit, ImporterState>(
                builder: (context, state) {
                  return IconButton(
                    onPressed: () {
                      context.read<ImporterCubit>().addOrUpdateToList(
                            state.importerId,
                            titleController?.text ?? '',
                            state.selectedCurrency ?? CurrencyEnum.usd,
                          );
                    },
                    icon: Icon(
                      Icons.done,
                      color: Colors.green,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
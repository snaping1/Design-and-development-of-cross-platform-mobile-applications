import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/di.dart';
import '../../main.dart';
import '../../models/protocol.dart';
import '../../routes.dart';
import '../../theme/theme_toggle_action.dart';
import '../profile_page.dart';
import 'bloc/home_bloc.dart';

// Для автономного запуска экрана: правая кнопка мыши → Run 'home_page.dart'
void main() {
  configureDependencies();
  runApp(
    MyApp(
      home: BlocProvider(
        create: (_) => getIt<HomeBloc>()..add(const LoadProtocolsEvent()),
        child: const HomePage(),
      ),
    ),
  );
}

/// Нижняя панель навигации приложения (Главная / Профиль)
class AppNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const AppNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      // Цвета панели задаются темой (navigationBarTheme)
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Главная',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Профиль',
        ),
      ],
    );
  }
}

/// Основной экран: вкладки «Главная» и «Профиль»
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _selectTab(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    // Без AppBar (вкладка «Профиль») — тёмные значки в строке состояния
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    return Scaffold(
      // На экране нет полей ввода — не ужимаем его, пока закрывается клавиатура
      resizeToAvoidBottomInset: _selectedIndex == 1,
      appBar: _selectedIndex == 0
          ? AppBar(
              title: const Text(
                'Сетевые протоколы',
                style: TextStyle(fontFamily: 'Pacifico', fontSize: 24),
              ),
              centerTitle: true,
              actions: [
                const ThemeToggleAction(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Обновить',
                  // Отправка события в блок из UI
                  onPressed: () =>
                      context.read<HomeBloc>().add(const LoadProtocolsEvent()),
                ),
              ],
            )
          : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          ProtocolsView(onSelectTab: _selectTab),
          ProfilePage(onBack: () => _selectTab(0)),
        ],
      ),
      bottomNavigationBar: AppNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
      ),
    );
  }
}

/// Содержимое вкладки «Главная» с адаптивной вёрсткой
class ProtocolsView extends StatelessWidget {
  final ValueChanged<int> onSelectTab;

  const ProtocolsView({super.key, required this.onSelectTab});

  // Для десктопа и веба — увеличенные вертикальные отступы
  static final bool _isDesktopOrWeb =
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;

  static final double _spacing = _isDesktopOrWeb ? 32 : 16;

  Future<void> _openDetail(BuildContext context, Protocol protocol) async {
    final tab = await Navigator.pushNamed(
      context,
      Routes.detail,
      arguments: protocol,
    );
    // С экрана детализации может вернуться выбранная вкладка NavigationBar
    if (tab is int) onSelectTab(tab);
  }

  BoxDecoration _boxDecoration(BuildContext context) => BoxDecoration(
    border: Border.all(color: Theme.of(context).colorScheme.outline),
    borderRadius: BorderRadius.circular(8),
  );

  Widget _protocolCard(BuildContext context, Protocol protocol) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Center(
        child: ListTile(
          leading: Icon(protocol.icon),
          title: Text(protocol.name),
          subtitle: Text(protocol.description),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _openDetail(context, protocol),
        ),
      ),
    );
  }

  /// Сообщение об ошибке с кнопкой повторной загрузки
  Widget _messageWithButton(
    BuildContext context, {
    required IconData icon,
    required String message,
    required String buttonText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            // Отправка события в блок из UI
            onPressed: () =>
                context.read<HomeBloc>().add(const LoadProtocolsEvent()),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Часть экрана, которая зависит от состояния блока
  List<Widget> _stateSlivers(
    BuildContext context,
    HomeState state,
    bool isWide,
  ) {
    switch (state) {
      case HomeInitial():
        // Ничего не загружено — область списка пустая
        // (событие загрузки отправляется сразу при создании блока)
        return const [];

      case HomeLoading():
        return const [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ];

      case HomeError(:final message):
        return [
          SliverToBoxAdapter(
            child: _messageWithButton(
              context,
              icon: Icons.error_outline,
              message: message,
              buttonText: 'Повторить',
            ),
          ),
        ];

      case HomeLoaded(:final protocols):
        if (protocols.isEmpty) {
          return const [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: Text('Список пуст')),
              ),
            ),
          ];
        }
        return _protocolsSlivers(context, protocols, isWide);
    }
  }

  /// Изображения и карточки загруженных протоколов
  List<Widget> _protocolsSlivers(
    BuildContext context,
    List<Protocol> protocols,
    bool isWide,
  ) {
    return [
      // Горизонтальный список изображений
      SliverToBoxAdapter(
        child: SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: protocols.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _openDetail(context, protocols[index]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    protocols[index].imagePath,
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      SliverToBoxAdapter(child: SizedBox(height: _spacing)),

      // Карточки пунктов: список или сетка в 2 столбца
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: isWide
            ? SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 88,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: _isDesktopOrWeb ? 20 : 10,
                ),
                itemCount: protocols.length,
                itemBuilder: (context, index) =>
                    _protocolCard(context, protocols[index]),
              )
            : SliverList.separated(
                itemCount: protocols.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: _isDesktopOrWeb ? 20 : 10),
                itemBuilder: (context, index) =>
                    _protocolCard(context, protocols[index]),
              ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Перестройка UI при изменении состояния блока
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Ширина более 600 — карточки в 2 столбца
            final isWide = constraints.maxWidth > 600;

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, _spacing, 16, 0),
                  sliver: SliverList.list(
                    children: [
                      // Название ПО
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: _boxDecoration(context),
                        child: const Center(
                          child: Text(
                            'Сетевые протоколы',
                            style: TextStyle(
                              fontFamily: 'Pacifico',
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: _spacing),

                      // Описание ПО
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: _boxDecoration(context),
                        child: const Text(
                          'Сетевые протоколы — это наборы правил и соглашений, '
                          'определяющих порядок обмена данными между устройствами в сети. '
                          'Они обеспечивают совместимость оборудования и программного '
                          'обеспечения разных производителей, а также надёжную передачу '
                          'информации на различных уровнях сетевой модели OSI.',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      SizedBox(height: _spacing),
                    ],
                  ),
                ),

                // Состояние блока: загрузка, ошибка или список протоколов
                ..._stateSlivers(context, state, isWide),

                // ФИО и группа
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, _spacing, 16, _spacing),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: _boxDecoration(context),
                          child: Icon(
                            Icons.person,
                            size: 36,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: _boxDecoration(context),
                            child: const Text(
                              'Тагин Н.В., группа ИКБО-61-23',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

# GithubSearch

Github Repos Search - Kotlin Multiplatform Mobile using Jetpack Compose, SwiftUI,
 FlowRedux, Coroutines Flow, Dagger Hilt, Koin Dependency Injection, shared KMP ViewModel, Clean Architecture


Minimal **Kotlin Multiplatform** project with SwiftUI, Jetpack Compose.
 - Android (Jetpack compose)
 - iOS (SwiftUI)

### Modern Development
 - Kotlin Multiplatform
 - Jetpack Compose
 - Kotlin Coroutines & Flows
 - Dagger Hilt
 - SwiftUI
 - Koin Dependency Injection
 - FlowRedux State Management
 - Shared KMP ViewModel
 - Clean Architecture

## Tech Stacks
 - Functional & Reactive programming with **Kotlin Coroutines with Flow**
 - **Clean Architecture** with **MVI** (Uni-directional data flow)
 - [**Multiplatform ViewModel and SavedStateHandle**](https://github.com/hoc081098/kmp-viewmodel) (save and restore states across process death)
 - **Multiplatform FlowRedux** State Management
 - [**Λrrow** - Functional companion to Kotlin's Standard Library](https://arrow-kt.io/)
   - [Either](https://arrow-kt.io/docs/apidocs/arrow-core/arrow.core/-either/)
   - [Monad Comprehensions](https://arrow-kt.io/docs/patterns/monad_comprehensions/)
   - [Option](https://arrow-kt.io/docs/apidocs/arrow-core/arrow.core/-option/)
   - [parZip](https://arrow-kt.io/docs/apidocs/arrow-fx-coroutines/arrow.fx.coroutines/par-zip.html)
 - Dependency injection
   - iOS: [**Koin**](https://insert-koin.io/)
   - Android: [**Dagger Hilt**](https://dagger.dev/hilt/)
 - Declarative UI
   - iOS: [**SwiftUI**](https://developer.apple.com/xcode/swiftui/)
   - Android: [**Jetpack Compose**](https://developer.android.com/jetpack/compose)
 - [Ktor client library](https://ktor.io/docs/getting-started-ktor-client-multiplatform-mobile.html) for networking
 - [Kotlinx Serialization](https://github.com/Kotlin/kotlinx.serialization) for JSON serialization/deserialization.
 - [Napier](https://github.com/AAkira/Napier) for Multiplatform Logging.
 - [FlowExt](https://github.com/hoc081098/FlowExt) provides many kotlinx.coroutines.
 - [Touchlab SKIE](https://skie.touchlab.co/) a Swift-friendly API Generator for Kotlin Multiplatform.
 - [kotlinx.collections.immutable](https://github.com/Kotlin/kotlinx.collections.immutable): immutable collection interfaces and implementation prototypes for Kotlin..
 - Testing
   - [Kotlin Test](https://kotlinlang.org/docs/multiplatform-run-tests.html) for running tests with Kotlin Multiplatform.
   - [Turbine](https://github.com/cashapp/turbine) for KotlinX Coroutines Flows testing.
   - [Mockative](https://github.com/mockative/mockative): mocking for Kotlin/Native and Kotlin Multiplatform using the Kotlin Symbol Processing API.
   - [Kotlinx-Kover](https://github.com/Kotlin/kotlinx-kover) for Kotlin Multiplatform code coverage.

# Screenshots

## Android (Light theme)
|                                                  |                                                   |                                                  |                                                  |
|:------------------------------------------------:|:-------------------------------------------------:|:------------------------------------------------:|:------------------------------------------------:|
| ![](screenshots/Screenshot_Android_Light_01.png) | ![](screenshots/Screenshot_Android_Light_02.png)  | ![](screenshots/Screenshot_Android_Light_03.png) | ![](screenshots/Screenshot_Android_Light_04.png) |

## Android (Dark theme)
|                                                  |                                                   |                                                  |                                                  |
|:------------------------------------------------:|:-------------------------------------------------:|:------------------------------------------------:|:------------------------------------------------:|
| ![](screenshots/Screenshot_Android_Dark_01.png)  |  ![](screenshots/Screenshot_Android_Dark_02.png)  | ![](screenshots/Screenshot_Android_Dark_03.png)  | ![](screenshots/Screenshot_Android_Dark_04.png)  |

## iOS (Light theme)
|                                              |                                              |                                               |                                              |
|:--------------------------------------------:|:--------------------------------------------:|:---------------------------------------------:|:--------------------------------------------:|
| ![](screenshots/Screenshot_iOS_Light_01.png) | ![](screenshots/Screenshot_iOS_Light_02.png) | ![](screenshots/Screenshot_iOS_Light_03.png)  | ![](screenshots/Screenshot_iOS_Light_04.png) |

## iOS (Dark theme)
|                                             |                                             |                                              |                                             |
|:-------------------------------------------:|:-------------------------------------------:|:--------------------------------------------:|:-------------------------------------------:|
| ![](screenshots/Screenshot_iOS_Dark_01.png) | ![](screenshots/Screenshot_iOS_Dark_02.png) | ![](screenshots/Screenshot_iOS_Dark_03.png)  | ![](screenshots/Screenshot_iOS_Dark_04.png) |

## Overall Architecture

### What is shared?
 - **domain**: Domain models, UseCases, Repositories.
 - **presentation**: ViewModels, ViewState, ViewSingleEvent, ViewAction.
 - **data**: Repository Implementations, Remote Data Source, Local Data Source.
 - **utils**: Utilities, Logging Library

### Unidirectional data flow - FlowRedux

 - My implementation. **Credits: [freeletics/FlowRedux](https://github.com/freeletics/FlowRedux)**
 - See more docs and concepts at [freeletics/RxRedux](https://github.com/freeletics/RxRedux)

<p align="center">
    <img src="https://raw.githubusercontent.com/freeletics/RxRedux/master/docs/rxredux.png" width="600" alt="RxRedux In a Nutshell"/>
</p>

```kotlin
public sealed interface FlowReduxStore<Action, State> {
  /**
   * The state of this store.
   */
  public val stateFlow: StateFlow<State>

  /**
   * @return false if cannot dispatch action (this store was closed).
   */
  public fun dispatch(action: Action): Boolean

  /**
   * Call this method to close this store.
   * A closed store will not accept any action anymore, thus state will not change anymore.
   * All [SideEffect]s will be cancelled.
   */
  public fun close()

  /**
   * After calling [close] method, this function will return true.
   *
   * @return true if this store was closed.
   */
  public fun isClosed(): Boolean
}
```

### Multiplatform ViewModel

```kotlin
open class GithubSearchViewModel(
  searchRepoItemsUseCase: SearchRepoItemsUseCase,
  private val savedStateHandle: SavedStateHandle,
) : ViewModel() {
  private val effectsContainer = GithubSearchSideEffectsContainer(searchRepoItemsUseCase)

  private val store = viewModelScope.createFlowReduxStore(
    initialState = GithubSearchState.initial(),
    sideEffects = effectsContainer.sideEffects,
    reducer = Reducer(flip(GithubSearchAction::reduce))
      .withLogger(githubSearchFlowReduxLogger())
  )

  val termStateFlow: NonNullStateFlowWrapper<String> = savedStateHandle.getStateFlow(TERM_KEY, "").wrap()
  val stateFlow: NonNullStateFlowWrapper<GithubSearchState> = store.stateFlow.wrap()
  val eventFlow: NonNullFlowWrapper<GithubSearchSingleEvent> = effectsContainer.eventFlow.wrap()

  init {
    store.dispatch(InitialSearchAction(termStateFlow.value))
  }

  @MainThread
  fun dispatch(action: GithubSearchAction): Boolean {
    if (action is GithubSearchAction.Search) {
      savedStateHandle[TERM_KEY] = action.term
    }
    return store.dispatch(action)
  }

  companion object {
    private const val TERM_KEY = "com.hoc081098.github_search_kmm.presentation.GithubSearchViewModel.term"

    /**
     * Used by non-Android platforms.
     */
    fun create(searchRepoItemsUseCase: SearchRepoItemsUseCase): GithubSearchViewModel =
      GithubSearchViewModel(searchRepoItemsUseCase, SavedStateHandle())
  }
}
```

### Platform ViewModel

#### Android

Extends `GithubSearchViewModel` to use `Dagger Constructor Injection`.

```kotlin
@HiltViewModel
class DaggerGithubSearchViewModel @Inject constructor(
  searchRepoItemsUseCase: SearchRepoItemsUseCase,
  savedStateHandle: SavedStateHandle,
) : GithubSearchViewModel(searchRepoItemsUseCase, savedStateHandle)
```

#### iOS

Conform to `ObservableObject` and use `@Published` property wrapper.

```swift
import Foundation
import Combine
import shared

@MainActor
class IOSGithubSearchViewModel: ObservableObject {
  private let vm: GithubSearchViewModel

  @Published private(set) var state: GithubSearchState
  @Published private(set) var term: String = ""
  let eventPublisher: AnyPublisher<GithubSearchSingleEventKs, Never>

  init(vm: GithubSearchViewModel) {
    self.vm = vm

    self.eventPublisher = vm.eventFlow.asNonNullPublisher()
      .assertNoFailure()
      .map(GithubSearchSingleEventKs.init)
      .eraseToAnyPublisher()

    self.state = vm.stateFlow.value
    vm.stateFlow.subscribe(
      scope: vm.viewModelScope,
      onValue: { [weak self] in self?.state = $0 }
    )

    self.vm
      .termStateFlow
      .asNonNullPublisher(NSString.self)
      .assertNoFailure()
      .map { $0 as String }
      .assign(to: &$term)
  }

  @discardableResult
  func dispatch(action: GithubSearchAction) -> Bool {
    self.vm.dispatch(action: action)
  }

  deinit {
    Napier.d("\(self)::deinit")
    vm.clear()
  }
}
```

# Building & Develop

- `Android Studio Hedgehog | 2023.1.1` (note: **Java 17 is now the minimum version required**).
- `Xcode 13.2.1` or later (due to use of new Swift 5.5 concurrency APIs).
- Clone project: `git clone https://github.com/hoc081098/GithubSearchKMM.git`
- Android: open project by `Android Studio` and run as usual.
- iOS
  ```shell
  # Cd to root project directory
  cd GithubSearchKMM

  # Setup
  sh scripts/run_ios.sh
  ```

  There's a *Build Phase* script that will do the magic. 🧞 <br>
  <kbd>Cmd</kbd> + <kbd>B</kbd> to build
  <br>
  <kbd>Cmd</kbd> + <kbd>R</kbd> to run.

  You can also build and run iOS app from Xcode as usual.

# LOC

```shell
--------------------------------------------------------------------------------
 Language             Files        Lines        Blank      Comment         Code
--------------------------------------------------------------------------------
 Kotlin                 116         7942          996          453         6493
 JSON                     7         3938            0            0         3938
 Swift                   16          960          124          102          734
 Markdown                 1          281           53            0          228
 Bourne Shell             2          249           28          116          105
 Batch                    1           92           21            0           71
 XML                      6           69            6            0           63
--------------------------------------------------------------------------------
 Total                  149        13531         1228          671        11632
--------------------------------------------------------------------------------
```

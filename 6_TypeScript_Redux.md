# 6 TypeScript 환경에서 Redux를 프로처럼 사용하기



![post-thumbnail](https://media.vlpt.us/post-images/velopert/64de2710-e591-11e9-a83d-c9d12745e080/ts-and-redux.png)

이번에 준비한 튜토리얼에서는 TypeScript 환경에서 Redux를 프로처럼 사용하는 방법을 다뤄보도록 하겠습니다. 왜 제목이 "프로처럼"이냐! 사실은 조금 주관적입니다. 이 튜토리얼에서는 지금까지 제가 다양한 TypeScript/Redux 관련 코드를 읽고, 작성해오면서 그 중에서 제가 맘에 들었던 구조를 소개시켜드리겠습니다.

그런데 프로처럼 사용해보기 전에, 당연히 기초부터 알아보아야겠지요? 먼저 기본적인 리덕스 코드 작성 방법을 알아보고, 나중에 프로처럼 사용해보는것도 배워보겠습니다.

이 튜토리얼에서는 정말 간단한 리덕스 예시인 카운터와 투두리스트를 만들어보게 됩니다.

> 이 튜토리얼에 사용되는 모든 코드는 [CodeSandbox](https://codesandbox.io/s/yw9gx) 에서 확인 할 수 있습니다.

## 프로젝트 만들고, 라이브러리 설치하기

리덕스를 적용한 리액트 프로젝트를 만들어봅시다.

```bash
$ npx create-react-app ts-react-redux-tutorial --typescript
$ cd ts-react-redux-tutorial
$ yarn add redux react-redux @types/react-redux
```

redux의 경우엔 자체적으로 TypeScript 지원이 됩니다. 하지만 react-redux의 경우 그렇지 않기 때문에 패키지명 앞에 `@types`를 붙인 패키지를 설치해주어야 합니다.

`@types`는 TypeScript 미지원 라이브러리에 TypeScript 지원을 받을 수 있게 해주는 써드파티 라이브러리입니다. 이에 관련된 소스코드는 [DefinitelyTyped](https://github.com/DefinitelyTyped/DefinitelyTyped) 라는 GitHub 레포에서 관리가 되고 있습니다.

라이브러리에서 공식 TypeScript지원이 되는지 안되는지 확인을 하시려면 직접 설치 후 불러와서 확인을 해보셔도 되고, GitHub레포를 열어서 `index.d.ts` 라는 파일이 존재하는지 확인하시면 됩니다.

## 카운터 리덕스 모듈 작성하기

가장 간단한 예시인 카운터를 구현하기 위한 리덕스 모듈을 작성해보겠습니다. 우리는 리덕스 관련 코드를 작성 할 때 [Ducks 패턴](https://github.com/erikras/ducks-modular-redux)을 사용할 것입니다. Ducks 패턴에서는 편의성을 위하여 액션의 `type`, 액션 생성함수, 리듀서를 모두 한 파일에 작성합니다.

src 디렉터리 안에 modules 디렉터리를 만들고 그 안에 counter.ts 파일을 만들어서 다음 코드들을 순서대로 입력해보세요.

#### src/modules/counter.ts

#### 1. 액션 type 선언

액션 type들을 선언해보겠습니다. 여기서의 "type"은 TypeScript의 type을 의미하는게 아니라 리덕스 액션 안에 들어가게 될 type값 입니다.

type을 선언 할 때에는 다음과 같이 문자열 뒤에 `as const` 라는 키워드를 붙여주셔야합니다.

```typescript
const INCREASE = 'counter/INCREASE' as const;
const DECREASE = 'counter/DECREASE' as const;
const INCREASE_BY = 'counter/INCREASE_BY' as const;
```

`as const`는 [**const assertions**](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-4.html#const-assertions)라는 TypeScript 문법입니다. 이 문법을 사용하면 우리가 추후 액션 생성함수를 통해 액션 객체를 만들게 됐을 때 type의 TypeScript 타입이 `string`이 되지 않고 실제값을 가르키게 됩니다.

![img](https://i.imgur.com/s1v07If.gif)

#### 2. 액션 생성 함수 선언

그 다음에는 액션 생성 함수들을 선언해보겠습니다. 액션 생성 함수를 작성 할 때에는 `function` 키워드를 사용해도 되고, 화살표 함수 문법을 사용해도 됩니다. 화살표 함수 문법을 사용하면 `return` 을 생략 할 수 있어서 깔끔하기 때문에, 우리는 화살표 함수를 사용하여 선언해보도록 할게요. 아까 작성한 코드 하단에 다음 코드를 작성해주세요.

```typescript
export const increase = () => ({ type: INCREASE });
export const decrease = () => ({ type: DECREASE });
export const increaseBy = (diff: number) => ({
  type: INCREASE_BY,
  payload: diff
});
```

여기서 `increase` 와 `decrease` 의 경우엔 함수에서 따로 파라미터를 받아오지 않습니다. `increaseBy`의 경우엔 `diff`라는 값을 파라미터로 받아와서 액션의 `payload`값으로 설정해줍니다. 이 과정에서 값의 이름을 `payload`로 바꿔주었는데 이는 [FSA 규칙](https://github.com/redux-utilities/flux-standard-action)을 따루기 위함입니다. 이 규칙을 따름으로써 액션 객체의 구조를 일관성 있게 가져갈 수 있어서 추후 리듀서에서 액션을 다룰 때에도 편하고, 읽기 쉽고, 액션에 관련된 라이브러리를 사용 할 수도 있게 해줍니다. 다만, 꼭 따라야 할 필요는 없으니 만약 여러분들이 FSA가 불편하면 굳이 이렇게 `payload` 라는 이름으로 넣을 필요는 없습니다.

추가적으로, 액션 생성 함수들은 추후 컨테이너 컴포넌트에서 불러와서 사용을 해야 하므로

#### 3. 액션 객체들에 대한 type 준비하기

여기서의 "type"은 TypeScript의 타입을 의미합니다. 나중에 우리가 리듀서를 작성 할 때 action 파라미터의 타입을 설정하기 위해서 우리가 만든 모든 액션들의 TypeScript 타입을 준비해주어야 합니다. 이는 다음과 같이 선언 할 수 있습니다.

```typescript
type CounterAction =
  | ReturnType<typeof increase>
  | ReturnType<typeof decrease>
  | ReturnType<typeof increaseBy>;
```

여기서 사용 된 `ReturnType` 은 함수에서 반환하는 타입을 가져올 수 있게 해주는 유틸 타입입니다.

![img](https://media.vlpt.us/post-images/velopert/c5228c00-e46b-11e9-9765-73247a4e2d1f/image.png)

우리가 이전에 액션의 `type` 값들을 선언 할 때 `as const` 라는 키워드를 사용했었지요? 만약 이 작업을 처리하지 않으면 `ReturnType`을 사용하게 됐을 때 `type` 의 타입이 무조건 `string` 으로 처리되어버립니다. 그렇게 되면 나중에 리듀서를 제대로 구현 할 수가 없어요.

#### 4. 상태의 타입과 상태의 초깃값 선언하기

이번에는 counter 모듈에서 관리할 상태의 타입과 상태의 초깃값을 선언하겠습니다.

```typescript
type CounterState = {
  count: number;
}

const initialState: CounterState = {
  count: 0
};
```

간단하죠? 리덕스 상태의 타입을 선언 할 때에는 `type` 을 쓰셔도 되고 `interface` 를 쓰셔도 됩니다. 둘 중에 하나만 선택 해서 앞으로 일관성 있게 계속 하나만 사용하시는 것을 권장드립니다.

#### 5. 리듀서 작성하기

마지막으로, 리듀서를 작성하고 내보내주겠습니다. 리듀서를 작성 하는 것은, 우리가 이전에 `useReducer`의 사용법을 배웠을 때랑 똑같습니다. 함수의 반환 타입에 상태의 타입을 넣는 것을 잊지 마세요. 이를 통하여 사소한 실수를 방지 할 수 있습니다.

```typescript
function counter(state: CounterState = initialState, action: CounterAction) {
  switch (action.type) {
    case INCREASE:
      return { count: state.count + 1 };
    case DECREASE:
      return { count: state.count - 1 };
    case INCREASE_BY:
      return { count: state.count + action.payload };
    default:
      return state;
  }
}

export default counter;
```

리듀서를 작성하는 과정에서 `case` 부분에서 액션의 `type` 값에 유효하지 않은 값을 넣게 된다면 다음과 같이 오류가 나타나게 됩니다.

![img](https://media.vlpt.us/post-images/velopert/6d7bd130-e46d-11e9-9765-73247a4e2d1f/image.png)

추가적으로, case 에 따라 액션 안에 어떤 값이 들어있는지도 아주 잘 알 수 있죠.

![img](https://media.vlpt.us/post-images/velopert/8445dcd0-e46d-11e9-a171-a5a10fd0b999/image.png)

리듀서를 다 작성하셨으면 추후 루트 리듀서를 만들 때 불러올 수 있도록 내보내주세요. 전체 코드는 이 [링크](https://gist.github.com/velopert/8abeed84856711b2b98d58b9503e335b)에서 확인 할 수 있습니다

모듈 작성이 이제 끝났습니다!

## 프로젝트에 리덕스 적용하기

이제 프로젝트에 리덕스를 적용해보겠습니다. 지금은 리듀서가 하나뿐이지만, 추후 우리가 다른 리듀서를 더 만들 것이므로 루트 리듀서를 만들어주도록 하겠습니다. modules 디렉터리에 index.ts 파일을 만들어서 다음과 같이 코드를 작성해주세요.

#### src/modules/index.ts

```typescript
import { combineReducers } from 'redux';
import counter from './counter';

const rootReducer = combineReducers({
  counter
});

export default rootReducer;

export type RootState = ReturnType<typeof rootReducer>;
```

루트 리듀서를 만들 때에는 일반 JavaScript 환경에서 할 때랑 방법이 동일한데, 주의하셔야 되는 부분은 `RootState` 라는 타입을 만들어서 내보내주어야 한다는 것 입니다. 이 타입은 추후 우리가 컨테이너 컴포넌트를 만들게 될 때 스토어에서 관리하고 있는 상태를 조회하기 위해서 `useSelector`를 사용 할 때 필요로 합니다.

자, 이제 루트 리듀서를 만들었으니 index.tsx 파일에서 스토어를 생성하고 Provider 컴포넌트를 사용하여 리액트 프로젝트에 리덕스를 적용해보세요.

#### index.tsx

```javascript
import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import App from './App';
import * as serviceWorker from './serviceWorker';
import { Provider } from 'react-redux';
import { createStore } from 'redux';
import rootReducer from './modules';

const store = createStore(rootReducer);

ReactDOM.render(
  <Provider store={store}>
    <App />
  </Provider>,
  document.getElementById('root')
);

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
```

## 카운터 프리젠테이셔널 컴포넌트 만들기

이제 프리젠테이셔널 컴포넌트를 만들어보겠습니다. 우리가 이번에는 프리젠테이셔널 컴포넌트와 컨테이너 컴포넌트를 구분해서 만들어보도록 하겠습니다. 하지만, 참고로 Dan Abramov님이 자신이 쓴 [Presentational and Container Components](https://medium.com/@dan_abramov/smart-and-dumb-components-7ca2f9a7c7d0) 포스트를 수정하면서 덧붙였듯이, 프리젠테이셔널/컨테이너 구조는 필수적인게 아닙니다. 따라서, 여러분들이 쓰기 싫다면 쓰지 않으셔도 무방합니다.

먼저, 이 구조로 컴포넌트들을 작성해보고, 그 다음에는 컨테이너를 따로 구분하지 않는다면 어떻게 구현하는게 좋을지도 다뤄보겠습니다.

src 디렉터리에 components 디렉터리를 만드시고 그 안에 Counter.tsx 를 다음과 같이 작성해보세요.

#### src/components/Counter.tsx

```typescript
import React from 'react';

type CounterProps = {
  count: number;
  onIncrease: () => void;
  onDecrease: () => void;
  onIncreaseBy: (diff: number) => void;
};

function Counter({
  count,
  onIncrease,
  onDecrease,
  onIncreaseBy
}: CounterProps) {
  return (
    <div>
      <h1>{count}</h1>
      <button onClick={onIncrease}>+1</button>
      <button onClick={onDecrease}>-1</button>
      <button onClick={() => onIncreaseBy(5)}>+5</button>
    </div>
  );
}

export default Counter;
```

컴포넌트에서 필요한 값과 함수들을 모두 props 로 받아오도록 처리하였습니다. 위 컴포넌트에서는 3개의 버튼을 보여주는데 3번째 버튼의 경우 클릭이 되면 5를 `onIncreaseBy` 함수의 파라미터로 설정하여 호출합니다.

## 카운터 컨테이너 컴포넌트 만들기

그 다음에는 리덕스 스토어 안에 있는 상태를 조회하여 사용하고, 액션도 디스패치하는 컨테이너 컴포넌트를 만들어봅시다.
src 디렉터리에 containers 디렉터리를 만들고, 그 안에 CounterContainer.tsx 파일을 생성하여 다음 코드를 작성해주세요.

#### src/containers/CounterContainer.tsx

```typescript
import React from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { RootState } from '../modules';
import { increase, decrease, increaseBy } from '../modules/counter';
import Counter from '../components/Counter';

function CounterContainer() {
  const count = useSelector((state: RootState) => state.counter.count);
  const dispatch = useDispatch();

  const onIncrease = () => {
    dispatch(increase());
  };

  const onDecrease = () => {
    dispatch(decrease());
  };

  const onIncreaseBy = (diff: number) => {
    dispatch(increaseBy(diff));
  };

  return (
    <Counter
      count={count}
      onIncrease={onIncrease}
      onDecrease={onDecrease}
      onIncreaseBy={onIncreaseBy}
    />
  );
}

export default CounterContainer;
```

TypeScript로 컨테이너 컴포넌트를 작성 할 때 특별한 점은 `useSelector` 부분에서 `state` 의 타입을 `RootState`로 지정해서 사용한다는 것 외에는 없습니다.

이제, 이 CounterContainer 컴포넌트를 App 컴포넌트에서 렌더링 해보세요.

#### src/App.tsx

```typescript
import React from 'react';
import CounterContainer from './containers/CounterContainer';

function App() {
  return <CounterContainer />;
}

export default App;
```

![img](https://media.vlpt.us/post-images/velopert/d29f7ca0-e52c-11e9-9081-b7873e23d164/image.png)

카운터 컴포넌트가 잘 나타났나요? 버튼들을 눌러서 잘 작동하는지 확인해보세요.

## 프리젠테이셔널 / 컨테이너 분리를 하지 않는다면?

만약 프리젠테이셔널 컴포넌트와 컨테이너 컴포넌트를 따로 분리하지 않는다면 어떻게 코드를 작성하는게 좋을까요? Dan Abramov님은 다음과 같이 언급했습니다.

> *"Hooks let me do the same thing without an arbitrary division".* [(원문)](https://medium.com/@dan_abramov/smart-and-dumb-components-7ca2f9a7c7d0#99d5)
> (번역) Hooks 를 사용하여 (컴포넌트를) 임의적으로 분리하지 않아도 똑같은 작업을 할 수 있다.

저는 처음에 이 문구를 봤을땐 잘 이해가 가질 않았습니다. Hooks 를 사용해서 똑같은 작업을 할 수 있다는게 어떤 의미일까요? Hooks를 사용해서 로직을 분리 할 수 있다는 것 까지는 이해를 하겠는데 과연 리덕스를 사용할때 정확히 어떻게 하라는걸까요? 프리젠테이셔널 컴포넌트에서 그냥 바로 `useSelector` / `useDispatch`를 사용하라는걸까요?

이게 도대체 뭔 소리일까 하고 열심히 저 문장을 곱씹고나니 드디어 이해할 수 있었습니다. 정말 간단한 의미였습니다. 컴포넌트를 사용 할 때 props 로 필요한 값을 받아와서 사용하게 하지 말고, `useSelector`와 `useDispatch`로 이루어진 커스텀 Hook을 만들어서 이를 사용하라는 의미입니다.

한번 Counter 컴포넌트를 리덕스와 연동하기 위하여 `useCounter` 라는 커스텀 Hook을 작성해보겠습니다.

src 디렉터리애 hooks 디렉터리를 만들고, 그 안에 useCounter.tsx 파일을 다음과 같이 작성해보세요.

#### src/hooks/useCounter.tsx

```typescript
import { useSelector, useDispatch } from 'react-redux';
import { RootState } from '../modules';
import { increase, decrease, increaseBy } from '../modules/counter';
import { useCallback } from 'react';

export default function useCounter() {
  const count = useSelector((state: RootState) => state.counter.count);
  const dispatch = useDispatch();

  const onIncrease = useCallback(() => dispatch(increase()), [dispatch]);
  const onDecrease = useCallback(() => dispatch(decrease()), [dispatch]);
  const onIncreaseBy = useCallback(
    (diff: number) => dispatch(increaseBy(diff)),
    [dispatch]
  );

  return {
    count,
    onIncrease,
    onDecrease,
    onIncreaseBy
  };
}
```

우리가 Container 를 작성하는 것과 비슷하게 리덕스와 연동하는 작업이 프리젠테이셔널 컴포넌트에서 분리되었지만, 컴포넌트가 아니라 Hook 형태로 구현이 되었지요. 그러면 이제 이 `useCounter` Hook을 프리젠테이셔널 컴포넌트에서 사용해주면 됩니다. 아니, 사실 이제부터는 프리젠테이셔널과 컨테이너의 구분이 사라지는거니까 굳이 프리젠테이셔널 컴포넌트라고 부를 필요도 없겠습니다.

Counter.tsx 파일을 다음과 같이 수정해주세요.

#### src/components/Counter.tsx

```typescript
import React from 'react';
import useCounter from '../hooks/useCounter';

function Counter() {
  const { count, onIncrease, onDecrease, onIncreaseBy } = useCounter();

  return (
    <div>
      <h1>{count}</h1>
      <button onClick={onIncrease}>+1</button>
      <button onClick={onDecrease}>-1</button>
      <button onClick={() => onIncreaseBy(5)}>+5</button>
    </div>
  );
}

export default Counter;
```

필요한 함수와 값을 props로 받아오는게 아니라, `useCounter` Hook 을 통해서 받아왔습니다!

이제 컨테이너 컴포넌트들은 불필요해졌으니, containers 디렉터리를 제거하세요. 그리고, App 컴포넌트에서 CounterContainer 대신 Counter 를 렌더링하도록 구현해보세요.

#### src/App.tsx

```typescript
import React from 'react';
import Counter from './components/Counter';

function App() {
  return <Counter />;
}

export default App;
```

이제, 이전과 똑같이 작동하는지 확인해보세요.

Hooks가 존재하기 전에는, 컨테이너 컴포넌트를 만들 때 `connect()` 함수를 통하여 HOC 패턴을 통하여 컴포넌트와 리덕스를 연동해주었기 때문에 props 로 필요한 값들을 전달해주는 것이 필수였었지만, 이제는 더 이상 그렇지 않습니다. 프리젠테이셔널 / 컨테이너 컴포넌트 패턴이 여러분이 이미 익숙하시다면 기존 패턴을 고수하는것도 괜찮습니다. 다만, 이렇게 Hooks를 통하여 로직을 분리하는것도 정말 괜찮은 패턴이니 새로 작성하는 컴포넌트부터 이렇게 커스텀 Hooks를 작성하는 방식으로 시도를 하는 것도 정말 좋은 방법이라고 생각합니다.

> 저 또한, 실무에서는 앞으로 새로 작성하는 컴포넌트부터 이 방식을 시도해보려고 합니다.

## 투두리스트 리덕스 모듈 만들기

계속해서 연습을 더 해보기 위하여 조금 더 복잡해진 (그럼에도 매우 간단한) 리덕스 관련 코드를 작성해보겠습니다. 이번에는 투두리스트를 만들기위한 리덕스 모듈을 준비하겠습니다. 이번에는 아까 구현했던 카운터와는 달리 액션객체를 만드는 과정에서 추가적으로 필요한 페이로드(payload) 값이 액션마다 다릅니다.

modules 디렉터리에 todos.ts 파일을 만드시고, 다음 코드들을 순서대로 작성해보세요.

#### src/modules/todos.ts

#### 1. 액션 type / 액션 생성함수 / 액션의 타입스크립트 타입 선언

먼저 액션에 관한 코드들 부터 작성을 해보겠습니다. 이전에 카운터를 구현할 때 작성했던 코드와 형식이 동일합니다.

```typescript
// 액션 type
const ADD_TODO = 'todos/ADD_TODO' as const;
const TOGGLE_TODO = 'todos/TOGGLE_TODO' as const;
const REMOVE_TODO = 'todos/REMOVE_TODO' as const;

// 액션 생성 함수
export const addTodo = (text: string) => ({
  type: ADD_TODO,
  payload: text
});

export const toggleTodo = (id: number) => ({
  type: TOGGLE_TODO,
  payload: id
});

export const removeTodo = (id: number) => ({
  type: REMOVE_TODO,
  payload: id
});

// 액션들의 타입스크립트 타입 준비
type TodosAction =
  | ReturnType<typeof addTodo>
  | ReturnType<typeof toggleTodo>
  | ReturnType<typeof removeTodo>;
```

#### 2. 상태를 위한 타입 및 초기 상태 선언

그 다음에는 상태를 위한 타입 및 초기 상태를 선언해주겠습니다. 이번 리덕스 모듈의 상태는 배열의 타입으로 준비해보겠습니다.

```typescript
// 상태를 위한 타입 선언
export type Todo = {
  id: number;
  text: string;
  done: boolean;
};
type TodosState = Todo[];

// 초깃값 설정
const initialState: TodosState = [
  { id: 1, text: '타입스크립트 배우기', done: true },
  { id: 2, text: '타입스크립트와 리덕스 함께 사용해보기', done: true },
  { id: 3, text: '투두리스트 만들기', done: false }
];
```

여기서 `Todo` 타입은 나중에 컴포넌트에서 불러와서 사용 할 것이기 때문에 내보내주었습니다. 초깃값에 들어있는 항목들의 내용은 여러분 마음대로 적어주세요. 빈 배열이여도 상관은 없습니다.

#### 3. 리듀서 구현하기

이제 리듀서를 구현해주겠습니다.

```typescript
function todos(state: TodosState = initialState, action: TodosAction): TodosState {
  switch (action.type) {
    case ADD_TODO:
      const nextId = Math.max(...state.map(todo => todo.id)) + 1;
      return state.concat({
        id: nextId,
        text: action.payload,
        done: false
      });
    case TOGGLE_TODO:
      return state.map(todo =>
        todo.id === action.payload ? { ...todo, done: !todo.done } : todo
      );
    case REMOVE_TODO:
      return state.filter(todo => todo.id !== action.payload);
    default:
      return state;
  }
}

export default todos;
```

새 항목을 만들 때 마다 고유 ID를 설정하기 위하여 현재 상태의 모든 항목들의 id 를 체크하고 그 중 가장 큰 값을 사용하도록 처리하였습니다. 리듀서를 모두 다 작성하고 나중에 루트 리듀서에 추가해줄 수 있도록 꼭 내보내주세요.

리듀서를 작성하는 과정에서 확인하셨겠지만, case에 따라 액션의 타입이 제대로 추론되고있습니다.

![img](https://i.imgur.com/vDGNHnQ.gif)

이제 todos 리덕스 모듈이 모두 작성완료되었습니다! 이 리덕스 모듈의 전체 코드는 이 [링크](https://gist.github.com/velopert/789442a55ed29f747c3ab82a22d127c5)에서 확인 할 수 있습니다.

### 루트 리듀서에 등록하기

우리가 방금 만든 리듀서를 루트 리듀서에 등록해봅시다.

#### src/modules/index.ts

```typescript
import { combineReducers } from 'redux';
import counter from './counter';
import todos from './todos';

const rootReducer = combineReducers({
  counter,
  todos
});

export default rootReducer;

export type RootState = ReturnType<typeof rootReducer>;
```

## 투두리스트 컴포넌트 준비하기

자! 이제 투두리스트를 구현하기 위한 컴포넌트들을 준비해주겠습니다. 이번에는 굳이 프리젠테이셔널/컨테이너 컴포넌트를 분리하지 않고, 아까 배웠었던 방식인 로직들을 Hooks 로 분리해서 구현하는 구조로 구현을 해보겠습니다.

우리가 앞으로 만들 컴포넌트는 총 3개입니다.

- **TodoInsert**: 새 항목을 등록 할 수 있는 컴포넌트입니다
- **TodoItem**: 할 일 정보를 보여주는 컴포넌트입니다
- **TodoList**: 여러개의 TodoItem 컴포넌트를 보여주는 컴포넌트입니다.

자, 그러면 components 디렉터리에 컴포넌트를 하나하나 작성해 내려가 봅시다.

#### src/components/TodoInsert.tsx

TodoInsert 컴포넌트는 새 항목을 등록 할 수 있는 컴포넌트입니다. 인풋의 상태는 `useState` 를 사용하여 로컬 상태로 관리해주겠습니다. 실제로 등록하는 함수의 경우 우리가 추후 커스텀 Hook 을 작성해서 구현해주도록 하겠습니다. 물론, 특별하게 복잡한 로직이 없기 때문에 그냥 여기에서 `useDispatch` 를 사용해도 상관은 없습니다.

```typescript
import React, { ChangeEvent, FormEvent, useState } from 'react';

function TodoInsert() {
  const [value, setValue] = useState('');
  const onChange = (e: ChangeEvent<HTMLInputElement>) => {
    setValue(e.target.value);
  };
  const onSubmit = (e: FormEvent) => {
    e.preventDefault();
    // TODO: 커스텀 Hook 사용해서 새 항목 등록
    setValue('');
  };

  return (
    <form onSubmit={onSubmit}>
      <input
        placeholder="할 일을 입력하세요."
        value={value}
        onChange={onChange}
      />
      <button type="submit">등록</button>
    </form>
  );
}

export default TodoInsert;
```

위 코드에서 `// TODO` 형태로 주석이 달린 부분은 나중에 다시 돌아와서 구현을 마저 해주겠습니다.

#### src/components/TodoItem.tsx

TodoItem 컴포넌트는 각 할 일 항목에 대한 정보를 보여주는 컴포넌트이며 텍스트 영역을 클릭하면 `done` 값이 바뀌고, 우측의 (X) 를 클릭하면 삭제됩니다.이번에는 간단한 스타일 적용을 위하여 css 파일도 작성을 해주겠습니다. 이 컴포넌트에서는 할 일 정보를 지니고 있는 `todo`를 props로 받아옵니다. 그리고 상태 토글 및 삭제를 해주는 함수 `onToggle`, `onRemove` 의 경우엔 추후 커스텀 Hook 을 작성하여 구현하도록 하겠습니다.

물론, 여러분들이 원하신다면 `onToggle`, `onRemove` 를 추후 TodoList 에서 props로 넣어주는 방식으로 구현하는 것도 괜찮습니다.

```typescript
import React from 'react';
import './TodoItem.css';
import { Todo } from '../modules/todos';

type TodoItemProps = {
  todo: Todo;
};

function TodoItem({ todo }: TodoItemProps) {
  // TODO: 커스텀 Hook 사용해서 onToggle / onRemove 구현
  return (
    <li className={`TodoItem ${todo.done ? 'done' : ''}`}>
      <span className="text">{todo.text}</span>
      <span className="remove">(X)</span>
    </li>
  );
}

export default TodoItem;
```

#### src/components/TodoItem.css

TodoItem 컴포넌트를 위한 CSS 파일을 작성해줍시다.

```css
.TodoItem .text {
  cursor: pointer;
}

.TodoItem.done .text {
  color: #999999;
  text-decoration: line-through;
}

.TodoItem .remove {
  color: red;
  margin-left: 4px;
  cursor: pointer;
}
```

#### src/components/TodoList.tsx

마지막 컴포넌트, TodoList 컴포넌트도 만들어봅시다. 이 컴포넌트에서는 추후 커스텀 Hook 을 작성하여 리덕스 스토어가 지니고 있는 상태의 `todos` 배열을 조회 할 것입니다.

```typescript
import React from 'react';
import { Todo } from '../modules/todos';
import TodoItem from './TodoItem';

function TodoList() {
  const todos: Todo[] = []; // TODO: 커스텀 Hook 사용하여 조회

  if (todos.length === 0) return <p>등록된 항목이 없습니다.</p>;
  
  return (
    <ul>
      {todos.map(todo => (
        <TodoItem todo={todo} key={todo.id} />
      ))}
    </ul>
  );
}

export default TodoList;
```

### App 에서 방금 만든 컴포넌트들 렌더링하기

이제 App 컴포넌트에서 방금 만든 컴포넌트들을 렌더링하는 작업을 해보겠습니다. 아직은 리덕스와 연동을 하지 않았기 때문에, 기능이 작동하지는 않을 것 입니다.

#### src/App.tsx

```typescript
import React from 'react';
import TodoInsert from './components/TodoInsert';
import TodoList from './components/TodoList';

function App() {
  return (
    <>
      <TodoInsert />
      <TodoList />
    </>
  );
}

export default App;
```

![img](https://media.vlpt.us/post-images/velopert/e691a390-e541-11e9-8821-372741169ca9/image.png)

위와 같은 화면이 나타났나요?

## 커스텀 Hook 작성해서 기능 구현하기

자, 이제 기능 구현을 위하여 커스텀 Hook 들을 작성해주겠습니다.

### useTodos

useTodos Hook 에서는 할 일 항목들을 조회하는 작업을 진행하겠습니다. hooks 디렉터리에 useTodos.ts 파일을 생성하여 다음 코드를 작성하세요.

#### src/hooks/useTodos.ts

```typescript
import { useSelector } from 'react-redux';
import { RootState } from '../modules';

export default function useTodos() {
  const todos = useSelector((state: RootState) => state.todos);
  return todos;
}
```

간단하지요? 그냥 `useSelector` 를 사용해서 상태를 조회하는 코드만 작성해주었습니다. 이제 이 코드를 TodoList 컴포넌트에서 사용해봅시다.

#### src/components/TodoList.tsx

```typescript
import React from 'react';
import TodoItem from './TodoItem';
import useTodos from '../hooks/useTodos';

function TodoList() {
  const todos = useTodos();

  if (todos.length === 0) return <p>등록된 항목이 없습니다.</p>;
  
  return (
    <ul>
      {todos.map(todo => (
        <TodoItem todo={todo} key={todo.id} />
      ))}
    </ul>
  );
}

export default TodoList;
```

여기까지 구현하시면 브라우저에서 초기 할 일 항목들이 보여질 것입니다.

![img](https://media.vlpt.us/post-images/velopert/7a4d0160-e542-11e9-bf92-f54dc4aad4b8/image.png)

### useAddTodo

이번에 만들 Hook 은 `useAddTodo` 입니다. 이 Hook은 새로운 할 일을 등록하는 함수를 사용 할 수 있게 해줍니다.

hooks 디렉터리에 useAddTodo.tsx 파일을 만들어서 다음 코드를 작성하세요.

#### src/hooks/useAddTodo.tsx

```typescript
import { useDispatch } from 'react-redux';
import { useCallback } from 'react';
import { addTodo } from '../modules/todos';

export default function useAddTodo() {
  const dispatch = useDispatch();
  return useCallback(text => dispatch(addTodo(text)), [dispatch]);
}
```

자, 이제 이 Hook 을 TodoInsert 에서 사용해볼까요?

#### src/components/TodoInsert.tsx

```typescript
import React, { ChangeEvent, FormEvent, useState } from 'react';
import useAddTodo from '../hooks/useInsertTodo';

function TodoInsert() {
  const [value, setValue] = useState('');
  const addTodo = useAddTodo();

  const onChange = (e: ChangeEvent<HTMLInputElement>) => {
    setValue(e.target.value);
  };
  const onSubmit = (e: FormEvent) => {
    e.preventDefault();
    addTodo(value);
    setValue('');
  };

  return (
    <form onSubmit={onSubmit}>
      <input
        placeholder="할 일을 입력하세요."
        value={value}
        onChange={onChange}
      />
      <button type="submit">등록</button>
    </form>
  );
}

export default TodoInsert;
```

여기까지 구현하시고 나면 새로운 항목을 등록하는 기능도 성공적으로 잘 작동 할 것입니다.

![img](https://media.vlpt.us/post-images/velopert/4034c340-e543-11e9-8821-372741169ca9/image.png)

### useTodoActions

이번에는, 할 일의 상태를 토글하는 함수와 할 일을 제거하는 함수를 제공해주는 `useTodoActions` 라는 Hook을 만들어보도록 하겠습니다. 이번에 만들 Hook에서는 이전과 조금 다르게 함수의 파라미터로 할 일의 `id` 값을 받아옵니다.

#### src/hooks/useTodoActions.ts

```typescript
import { useDispatch } from 'react-redux';
import { useCallback } from 'react';
import { toggleTodo, removeTodo } from '../modules/todos';

export default function useTodoActions(id: number) {
  const dispatch = useDispatch();

  const onToggle = useCallback(() => dispatch(toggleTodo(id)), [dispatch, id]);
  const onRemove = useCallback(() => dispatch(removeTodo(id)), [dispatch, id]);

  return { onToggle, onRemove };
}
```

이렇게 Hook 을 만드시면, TodoItem에서 간편하게 사용 할 수 있답니다.

#### src/components/TodoItem.tsx

```typescript
import React from 'react';
import './TodoItem.css';
import { Todo } from '../modules/todos';
import useTodoActions from '../hooks/useTodoActions';

export type TodoItemProps = {
  todo: Todo;
};

function TodoItem({ todo }: TodoItemProps) {
  const { onToggle, onRemove } = useTodoActions(todo.id);

  return (
    <li className={`TodoItem ${todo.done ? 'done' : ''}`}>
      <span className="text" onClick={onToggle}>
        {todo.text}
      </span>
      <span className="remove" onClick={onRemove}>
        (X)
      </span>
    </li>
  );
}

export default TodoItem;
```

정말 간단하지요? 이것으로 투두리스트의 구현이 모두 끝났습니다. 토글과 삭제가 잘 이루어지는지 확인해보세요.

![img](https://i.imgur.com/Tolhpiw.gif)

## typesafe-actions로 리덕스 모듈 리팩토링하기

지금까지 작성한 코드도 충분히 괜찮지만, 리덕스 모듈을 조금 더 개선해보도록 하겠습니다. [typesafe-actions](https://github.com/piotrwitek/typesafe-actions)라는 라이브러리를 사용하면 액션과 리듀서를 준비하는 작업을 훨씬 편하게 할 수 있답니다. 비슷한 류로 [redux-actions](https://github.com/redux-utilities/redux-actions)라는 라이브러리가 있지만, TypeScript 환경에서 사용하기에는 조금 별로입니다. 공식적으로 TypeScript 지원을 해주는 것이 아니기 때문에 레퍼런스도 별로 없고, 일단 사용을 해보시면 typesafe-actions가 훨씬 더 편합니다.

우선 해당 라이브러리를 설치해주세요.

```bash
$ yarn add typesafe-actions
```

### counter.ts 리팩토링

카운터 관련 리덕스 모듈 먼저 리팩토링을 해봅시다.

#### src/modules/counter.ts

#### 1. 필요한 함수 / 타입 import 하기

우선, 코드의 상단에 다음 3가지 유틸 함수 및 타입을 불러오세요

```typescript
import {
  createStandardAction,
  ActionType,
  createReducer
} from 'typesafe-actions';
```

#### 2. 액션 type 선언 할 때 as const 지우기

그리고, 액션의 type 을 선언 할 때 우리가 기존에 `as const` 를 붙여줬었는데, typesafe-actions를 사용하시면 붙일 필요가 없습니다. `as const` 를 지워주세요.

```typescript
const INCREASE = 'counter/INCREASE';
const DECREASE = 'counter/DECREASE';
const INCREASE_BY = 'counter/INCREASE_BY';
```

#### 3. createStandardAction으로 액션 생성 함수 만들기

자, 이제 액션 생성 함수를 선언 할 차례입니다. 액션 생성 함수를 만들 때에는 `createStandardAction` 이라는 함수를 사용하는데요, 사용법은 다음과 같습니다.

```typescript
export const increase = createStandardAction(INCREASE)();
// () => ({ type: INCREASE })
export const decrease = createStandardAction(DECREASE)();
// () => ({ type: DECREASE }) 
export const increaseBy = createStandardAction(INCREASE_BY)<number>();
// (payload: number) => ({ type: INCREASE_BY, payload })
```

액션의 페이로드로 들어가는 값은 Generic을 사용하여 정해줄 수 있으며, 만약 액션의 페이로드에 아무것도 필요 없다면 Generic을 생략하시면 됩니다.

가끔씩은 액션 생성 함수로 파라미터로 넣어주는 값과 액션의 페이로드 값이 완벽히 일치하지 않을 때가 있습니다. 예를 들어 다음과 같은 상황이 있지요.

```typescript
const createItem = (name: string) => ({ type: CREATE_ITEM, payload: { id: nanoid(), name } });
```

위 코드 처럼, id값을 [nanoid](https://www.npmjs.com/package/nanoid)같은 라이브러리를 사용하여 고유 값을 생성하여 넣어주고 싶을 때도 있을 것입니다. 그럴 때에는 코드를 다음과 같이 작성하면 됩니다.

```typescript
const createItem = createStandardAction(CREATE_ITEM).map(name => ({ payload: { id: nanoid(), name } }));
```

#### 4. 액션의 객체 타입 만들기

이전에 우리가 액션들의 객체 타입을 만들 떄에는 `ReturnType` 유틸 타입을 선언했었습니다. 다음과 같이 말이죠.

```typescript
ReturnType<typeof increaseBy>
```

typesafe-actions에 들어있는 `ActionType` 유틸 타입을 사용하면 액션들의 객체 타입을 만드는 작업을 더욱 짧은 코드로 작성 할 수 있습니다.

```typescript
const actions = { increase, decrease, increaseBy };
type CounterAction = ActionType<typeof actions>;
```

`ActionType`을 사용 할 때에는 이렇게 `actions` 라는 객체에 모든 액션 생성함수를 넣은 다음에, `ActionType`로 감싸주시면 됩니다.

#### 5. createReducer로 리듀서 만들기

이제 리듀서를 만들 차례입니다. `createReducer`를 사용하면 리듀서를 `switch/case` 문이 아닌 object map 형태로 구현 할 수 있어서 코드가 더욱 간결해집니다. 그리고 당연히, 타입 지원도 잘 이루어집니다.

```typescript
const counter = createReducer<CounterState, CounterAction>(initialState, {
  [INCREASE]: state => ({ count: state.count + 1 }),
  [DECREASE]: state => ({ count: state.count - 1 }),
  [INCREASE_BY]: (state, action) => ({ count: state.count + action.payload })
});
```

`createReducer` 를 사용 할 때에는 Generic 으로 상태의 타입과 액션들의 타입을 넣어주어야 합니다. `createReducer`에서는 이를 사용하여 내부에 각각 액션들을 위하여 구현할 함수에서 타입을 추론합니다.

이제 counter 모듈의 리팩토링이 모두 끝났습니다. 이 리덕스 모듈의 전체 코드는 이 [링크](https://gist.github.com/velopert/4a27f50754c99f42c0f348eeec665990)에서 확인 할 수 있습니다.

### Counter 컴포넌트 렌더

자, 이제 Counter 컴포넌트가 잘 작동하는지 확인해봅시다. App 컴포넌트에서 Counter를 렌더해보세요.

#### src/App.tsx

```typescript
import React from 'react';
import Counter from './components/Counter';

function App() {
  return (
    <Counter />
  );
}

export default App;
```

이전과 똑같이 잘 작동하는지 확인해보세요.

### counter 리듀서를 메서드 체이닝 방식을 통해 구현하기

`createReducer`를 사용 할 때 우리가 방금 했었던 것 처럼 함수들로 이루어진 object map 형태로 리듀서를 구현 할 수도 있고, [메서드 체이닝 방식](https://www.npmjs.com/package/typesafe-actions#using-createreducer-api-with-type-free-syntax)을 통해서 구현 할 수 있습니다. 한번 이방식을 통하여 counter 리듀서를 구현해보겠습니다.

#### src/modules/counter.ts

counter 모듈의 리듀서쪽 코드를 다음과 같이 대체해보세요.

```typescript
const counter = createReducer<CounterState, CounterAction>(initialState)
  .handleAction(INCREASE, state => ({ count: state.count + 1 }))
  .handleAction(DECREASE, state => ({ count: state.count - 1 }))
  .handleAction(INCREASE_BY, (state, action) => ({
    count: state.count + action.payload
  }));
```

`createReducer`를 사용한다음에 메서드 체이닝을 통하여 `handleAction` 함수에 첫번째 파라미터에는 액션의 타입, 두번째 파라미터에는 업데이터 함수를 작성해주시면 됩니다.

어떤가요? 이 방식도 꽤나 편하죠? 취향에 따라 맘에 드는 방식을 택하시면 됩니다. 저는 개인적으로, object map의 형태를 사용하는게 가독성이 더 좋다고 생각합니다.

하지만, 이 방식의 장점은, `handleAction`의 첫번째 파라미터에 액션의 문자열 타입 외에도, 액션 생성 함수를 넣어도 작동한다는 것입니다. 만약에 액션의 문자열 타입 대신 액션 생성 함수를 넣게 된다면, 우리가 사전에 액션들의 문자열 타입들을 선언 할 필요도 없고 심지어 액션들의 객체 타입 또한 준비해줄 필요가 없습니다. 코드를 다음과 같이 작성 할 수가 있다는 의미입니다.

```typescript
import { createStandardAction, createReducer } from 'typesafe-actions';

export const increase = createStandardAction('counter/INCREASE')();
export const decrease = createStandardAction('counter/DECREASE')();
export const increaseBy = createStandardAction('counter/INCREASE_BY')<number>(); // payload 타입을 Generics 로 설정해주세요.

type CounterState = {
  count: number;
};

const initialState: CounterState = {
  count: 0
};

const counter = createReducer(initialState)
  .handleAction(increase, state => ({ count: state.count + 1 }))
  .handleAction(decrease, state => ({ count: state.count - 1 }))
  .handleAction(increaseBy, (state, action) => ({
    count: state.count + action.payload
  }));

export default counter;
```

메서드 체이닝 방식이 object map 방식보단 코드가 잘 읽히진 않지만, 코드 여러줄을 생략 할 수 있다는 점에서는 정말 매력있는 방식이라고 생각합니다. 이렇게 액션의 문자열 타입이 아니라 액션 생성 함수를 넣어도 잘 작동하는 이유는, `createStandardAction` 을 통해서 만드는 액션 생성 함수는 `getType` 라는 함수를 지니고 있기 때문입니다 [(참고)](https://github.com/piotrwitek/typesafe-actions/blob/1aba2ce503c80f9ee9dc969883708b6d7be67bf2/src/create-custom-action.ts#L27-L32).

### todos 리덕스 모듈 리팩토링하기

이어서, todos 리덕스 모듈도 리팩토링 해보겠습니다. 방금 counter 모듈을 리팩토링 한 방식과 동일하게 진행을 하시면 됩니다.

#### src/modules/todos.ts

#### 1. 상단에 필요한 함수와 타입 import하기

```typescript
import {
  createStandardAction,
  ActionType,
  createReducer
} from 'typesafe-actions';
```

#### 2. 액션의 타입 선언, 액션 생성 함수 만들기, 액션 객체 타입 준비

```typescript
// 액션 type
const ADD_TODO = 'todos/ADD_TODO';
const TOGGLE_TODO = 'todos/TOGGLE_TODO';
const REMOVE_TODO = 'todos/REMOVE_TODO';

// 액션 생성 함수
export const addTodo = createStandardAction(ADD_TODO)<string>();
export const toggleTodo = createStandardAction(TOGGLE_TODO)<number>();
export const removeTodo = createStandardAction(REMOVE_TODO)<number>();

// 액션들의 타입스크립트 타입 선언
const actions = { addTodo, toggleTodo, removeTodo };
type TodosAction = ActionType<typeof actions>;
```

#### 3. 리듀서 createReducer 로 구현하기

```typescript
const todos = createReducer<TodosState, TodosAction>(initialState, {
  [ADD_TODO]: (state, { payload: text }) =>
    state.concat({
      id: Math.max(...state.map(todo => todo.id)) + 1,
      text,
      done: false
    }),
  [TOGGLE_TODO]: (state, { payload: id }) =>
    state.map(todo => (todo.id === id ? { ...todo, done: !todo.done } : todo)),
  [REMOVE_TODO]: (state, { payload: id }) =>
    state.filter(todo => todo.id !== id)
});
```

object map형태로 구현하는 과정에서 `action` 객체를 구조 분해 (Object Destructuring) 함으로써 payload의 이름을 원하는 이름으로 바꿔줄 수 있습니다. 이를 통하여 업데이터 함수의 가독성을 더욱 높일 수 있죠.

### TodoInsert / TodoList 렌더

이제 아까 렌더했던 카운터를 지우고, 투두리스트에 필요한 컴포넌트들인 TodoInsert, TodoList 를 App에서 렌더해보세요.

#### src/App.tsx

```typescript
import React from 'react';
import TodoInsert from './components/TodoInsert';
import TodoList from './components/TodoList';

function App() {
  return (
    <>
      <TodoInsert />
      <TodoList />
    </>
  );
}

export default App;
```

이전과 똑같이 잘 작동하고 있나요?

### 리덕스 모듈 여러 파일로 분해하기

우리는 Ducks 패턴을 사용하여 리덕스에 관련된 코드를 기능별로 한 파일에 모두 모아서 작성을 하고 있습니다. 액션이 몇개 없을 때에는 꽤나 편리한 방식이긴 한데, 만약에 액션의 갯수가 20개가 넘어간다면 파일의 코드 길이가 엄청나게 길어져서 유지보수 하기가 힘들어질 수 있습니다. 심지어 우리는 현재 TypeScript를 사용하고 있기 때문에 일반 JavaScript를 사용할 때와 달리 타입에 관련된 코드를 준비해야되서 더더욱 코드의 길이가 길어지죠.

그렇다고 해서 Ducks 패턴을 완전히 포기하고, 널리 알려져있고 또 리덕스 공식 문서에서도 다루는 방식인 actions 디렉터리와 reducers 디렉터리를 분리하는건 아무래도 맘에 들지 않습니다.

```null
actions/
  counter.ts
  todos.ts
components/
  ...
lib/
  ...
reducers/
  counter.ts
  todos.ts
types/
  counter.ts
  todos.ts
```

이 구조를 사용하면 파일끼리 너무 멀리멀리 떨어져있게 됩니다. 그러면 새로운 액션을 추가 할 때마다 파일 탐색기에서 이리저리 스크롤을 해야되는데, 저 같은 경우는 이는 정말 불편하다고 생각합니다.

이에 대한 대안으로 제가 소개드릴 방법은, 사실 굉장히 간단합니다. 파일을 여러개로 분리해서 작성하긴하는데 하나의 디렉터리에 작성하는 것 입니다.

다음과 같이 말이죠.

```null
modules/
  todos/
    actions.ts
    index.ts
    reducer.ts
    types.td
  counter.ts
```

이 구조의 장점은, 모듈이 복잡해졌을때에는 디렉터리를 만들어서 그 안에 파일들을 분리해서 작성 할 수도 있고, 액션이 몇개 없는 정말 간단한 리덕스 모듈이라면 기존에 했던 방식 그대로 한 파일에 작성 할 수도 있다는 것 입니다.

한번, 이 구조를 사용하여 todos 리덕스 모듈을 리팩토링해보겠습니다.

우선 modules 디렉터리에 todos 디렉터리를 만들고 기존 todos.ts 를 그 안에 넣어서 index.ts 로 이름을 바꾸어주어야 하는데요, VS Code 에서는 이 작업을 엄청 간단하게 할 수 있습니다. 이 방법을 모르시는 분들이 많은데 제가 꿀팁을 방출해보겠습니다.

![img](https://i.imgur.com/VYmSLJ1.gif)

정말 편하죠?

자 이제, 기존 리덕스 모듈에서 코드들을 잘라내서 actions.ts, types.ts, reducer.ts 를 순서대로 작성해봅시다.

#### src/modules/todos/actions.ts

actions.ts 파일에는 액션들의 문자열 타입과 액션 생성 함수들을 선언하세요. 여기서 액션들의 문자열 타입도 내보내주셔야 합니다. 리듀서 만들 때 불러와서 사용해야 하기 때문이죠.

```typescript
import { createStandardAction } from 'typesafe-actions';

// 액션 type
export const ADD_TODO = 'todos/ADD_TODO';
export const TOGGLE_TODO = 'todos/TOGGLE_TODO';
export const REMOVE_TODO = 'todos/REMOVE_TODO';

// 액션 생성 함수
export const addTodo = createStandardAction(ADD_TODO)<string>();
export const toggleTodo = createStandardAction(TOGGLE_TODO)<number>();
export const removeTodo = createStandardAction(REMOVE_TODO)<number>();
```

#### src/modules/todos/types.ts

그 다음에는 types.ts 파일을 만들어서 여기에 상태의 타입과 액션의 타입을 준비해주세요. 우리가 actions 파일을 따로 만들었기 때문에 액션 타입을 준비하는 작업이 더욱 쉬워집니다.

```typescript
import { ActionType } from 'typesafe-actions';
import * as actions from './actions';

export type TodosAction = ActionType<typeof actions>;

export type Todo = {
  id: number;
  text: string;
  done: boolean;
};

export type TodosState = Todo[];
```

#### src/modules/todos/reducer.ts

그 다음에는, reducer.ts 파일을 만들어서 초기 상태와 리듀서 코드를 넣어주세요. 기존 리듀서 코드를 붙여넣으시고, 빨간줄이 그어지는 부분에 텍스트 커서를 옮긴 후 Ctrl + Space 키를 눌러서 자동 import 를 하시면 편합니다.

![img](https://i.imgur.com/uZ5BbIJ.gif)

#### src/modules/todos/index.ts

마지막으로, index.ts 에 있는 모든 코드를 다 지우시고, actions, types, reducer 에서 내보낸 것들을 불러와서 바로 내보내는 작업을 해주세요. 이 작업을 해주는 이유는 기존에 todos.ts 파일을 의존하던 곳을 (예: 루트 리듀서, Hook, 컴포넌트) 수정하지 않고도 잘 작동하게 하기 위함입니다.

```typescript
export { default } from './reducer'; // reducer 를 불러와서 default로 내보내겠다는 의미
export * from './actions'; // 모든 액션 생성함수들을 불러와서 같은 이름들로 내보내겠다는 의미
export * from './types'; // 모든 타입들을 불러와서 같은 이름들로 내보내겠다는 의미
```

이제 파일을 분리하는 작업이 모두 끝났습니다! 기본적으로, 불러와서 사용하던 파일의 경로가 바뀌어버리면 리액트 개발서버에서는 에러가 발생해버리는데요, 개발서버를 종료 후 다시 실행해주시면 에러가 해결됩니다.

## 정리

수고하셨습니다! 이제, 여러분들은 TypeScript 환경에서 Redux를 제대로 사용 할 수 있게 되셨습니다! 우리가 이번 튜토리얼에서 다룬 핵심들을 정리해보자면 다음과 같습니다.

1. 컨테이너 컴포넌트를 분리하는 대신에 커스텀 Hook을 작성하여 분리하는 방식도 시도해보자
2. typesafe-actions 를 사용하여 리덕스 모듈을 간단하게 작성하자
3. 리덕스 모듈이 너무 커질 것 같으면 여러 파일로 분리해서 작성하자, 단 한 디렉터리에 정리해서 관리하자.

우리가 이번에 다룬 방식이 무조건 최고의 방식은 아닙니다. 분명히 더 좋은 구조도 있을 것입니다. **코드를 어떻게 하면 더 깔끔하게 정리 할 수 있을까 끝없이 고민하고, 시도해보세요.** 더 좋은 아이디어가 있으시거나, 나중에 떠오르시게 되면 댓글로 알려주세요 :D

다음 튜토리얼에서는 Redux Middleware를 사용하는 방법을 다뤄보도록 하겠습니다.
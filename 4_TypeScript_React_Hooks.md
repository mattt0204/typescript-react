# 타입스크립트로 리액트 Hooks 사용하기 (useState, useReducer, useRef)

난 섹션에서는 타입스크립트가 적용된 리액트 프로젝트를 만드는 방법과, 타입스크립트로 컴포넌트를 작성하는 방법을 배웠습니다.

이번 섹션에서는 타입스크립트를 사용하는 리액트 컴포넌트에서 `useState` 및 `useReducer` 를 사용하여 컴포넌트의 상태를 관리하는 방법과 `useRef` 를 사용하여 컴포넌트 내부에서 관리하는 변수 및 DOM 을 이용하는 방법에 대해서 알아보겠습니다.

## useState 및 이벤트 관리

타입스크립트 환경에서 `useState` 를 사용하는 방법과, 이벤트를 다루는 방법을 배워봅시다.

### 카운터 만들기

먼저 정말 간단한 예제이며, 여러분들이 아마 지금까지 어쩌면 몇십번은 만들어봤을, 카운터를 `useState` Hook 을 사용하여 구현해보겠습니다.

src 디렉터리에 Counter.tsx 파일을 생성 후 다음과 같이 코드를 작성해주세요.

#### src/Counter.tsx

```typescript
import React, { useState } from 'react';

function Counter() {
  const [count, setCount] = useState<number>(0);
  const onIncrease = () => setCount(count + 1);
  const onDecrease = () => setCount(count - 1);
  return (
    <div>
      <h1>{count}</h1>
      <div>
        <button onClick={onIncrease}>+1</button>
        <button onClick={onDecrease}>-1</button>
      </div>
    </div>
  );
}

export default Counter;
```

타입스크립트 없이 리액트 컴포넌트를 작성하는 것과 별반 차이가 없습니다. `useState` 를 사용하실때 `useState()` 와 같이 Generics 를 사용하여 해당 상태가 어떤 타입을 가지고 있을지 설정만 해주시면 됩니다.

이 컴포넌트가 잘 작동하는지 App 에서 렌더링해서 확인을 해볼까요?

#### src/App.tsx

```typescript
import React from 'react';
import Counter from './Counter';

const App: React.FC = () => {
  return <Counter />;
};

export default App;
```

![img](https://i.imgur.com/sA0zbGs.png)

아주 잘 작동하고 있습니다. 그런데 참고로 `useState`를 사용 할 때 `Generics` 를 사용하지 않아도 알아서 타입을 유추하기 때문에 생략해도 상관없습니다.

#### src/Counter.tsx

```typescript
import React, { useState } from 'react';

function Counter() {
  const [count, setCount] = useState(0);
  const onIncrease = () => setCount(count + 1);
  const onDecrease = () => setCount(count - 1);
  return (
    <div>
      <h1>{count}</h1>
      <div>
        <button onClick={onIncrease}>+1</button>
        <button onClick={onDecrease}>-1</button>
      </div>
    </div>
  );
}

export default Counter;
```

![img](https://i.imgur.com/EARVf95.png)

그래서 사실상 안하셔도 무방합니다..! 그렇다면 `useState` 를 사용 할 때 어떤 상황에 Generics 를 사용하는게 좋을까요?

바로, 상태가 `null`일 수도 있고 아닐수도 있을때 Generics 를 활용하시면 좋습니다.

```typescript
type Information = { name: string; description: string };
const [info, setInformation] = useState<Information | null>(null);
```

추가적으로 상태의 타입이 까다로운 구조를 가진 객체이거나 배열일 때는 Generics 를 명시하는 것이 좋습니다.

```typescript
type Todo = { id: number; text: string; done: boolean };
const [todos, setTodos] = useState<Todo[]>([]);
```

배열인 경우에는 위와 같이 빈 배열만 넣었을 때 해당 배열이 어떤 타입으로 이루어진 배열인지 추론 할 수 없기 때문에 Generics 를 명시하셔야 합니다. 만약 Generics 를 사용하지 않는다면 다음과 같이 할 수도 있긴 하지만 코드가 별로 예쁘지 않습니다.

```typescript
type Todo = { id: number; text: string; done: boolean };
const [todos, setTodos] = useState([] as Todo[]);
```

여기서 사용된 `as` 는 [Type Assertion](https://www.typescriptlang.org/docs/handbook/basic-types.html#type-assertions) 이라는 문법인데요, 특정 값이 특정 타입이다라는 정보를 덮어 쓸 수 있는 문법입니다.

### 인풋 상태 관리하기

이번에는 인풋의 상태를 관리하는 방법을 다뤄보도록 하겠습니다. 이벤트를 다뤄야 하기 때문에 타입을 지정하는것이 처음엔 어떻게 해야 할지 헷갈릴수도 있을텐데, 한번 어떻게하는지 알고나면 매우 쉽습니다.

MyForm 이라는 컴포넌트를 다음과 같이 작성해보세요.

#### src/MyForm.tsx

```typescript
import React, { useState } from 'react';

type MyFormProps = {
  onSubmit: (form: { name: string; description: string }) => void;
};

function MyForm({ onSubmit }: MyFormProps) {
  const [form, setForm] = useState({
    name: '',
    description: ''
  });

  const { name, description } = form;

  const onChange = (e: any) => {
    // e 값을 무엇으로 설정해야할까요?
    // 일단 모를떄는 any 로 설정합니다.
  };

  const handleSubmit = (e: any) => {
    // 여기도 모르니까 any 로 하겠습니다.
  };

  return (
    <form onSubmit={handleSubmit}>
      <input name="name" value={name} onChange={onChange} />
      <input name="description" value={description} onChange={onChange} />
      <button type="submit">등록</button>
    </form>
  );
}

export default MyForm;
```

여기서 e 객체의 타입이 무엇일지, 타입스크립트를 처음 쓰는 사람이라면 모르실겁니다. 그렇다고 해서 구글에 "TypeScript react onChange event" 라고 검색하실 필요는 없습니다! e 객체의 타입이 무엇인지 외우실 필요도 없습니다. 그냥 커서를 `onChange` 에 올려보세요.

![img](https://i.imgur.com/PzrJW06.png)

커서를 올리면 어떤 타입을 사용해야하는지 알려줍니다. 그러면 그냥 마우스로 드래그해서 복사하시면 됩니다. (마우스 커서가 박스 밖으로 나가지 않게 조심히 움직이셔야 합니다)

그럼, `onChange` 의 e 객체의 타입을 `React.ChangeEvent`로 지정해서 구현을 하고, onSubmit도 마찬가지로 커서를 올리면 나타나는 `React.FormEvent` 를 e 객체의 타입으로 지정해서 구현해보겠습니다.

#### src/MyForm.tsx

```typescript
import React, { useState } from 'react';

type MyFormProps = {
  onSubmit: (form: { name: string; description: string }) => void;
};

function MyForm({ onSubmit }: MyFormProps) {
  const [form, setForm] = useState({
    name: '',
    description: ''
  });

  const { name, description } = form;

  const onChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setForm({
      ...form,
      [name]: value
    });
  };

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    onSubmit(form);
    setForm({
      name: '',
      description: ''
    }); // 초기화
  };

  return (
    <form onSubmit={handleSubmit}>
      <input name="name" value={name} onChange={onChange} />
      <input name="description" value={description} onChange={onChange} />
      <button type="submit">등록</button>
    </form>
  );
}

export default MyForm;
```

이제, 잘 작동하는지 App 에서 렌더링해서 확인을 해볼까요?

#### src/App.tsx

```typescript
import React from 'react';
import MyForm from './MyForm';

const App: React.FC = () => {
  const onSubmit = (form: { name: string; description: string }) => {
    console.log(form);
  };
  return <MyForm onSubmit={onSubmit} />;
};

export default App;
```

![img](https://i.imgur.com/1cX7HgO.png)

매우 잘 작동하고 있습니다!

## useReducer

타입스크립트 환경에서 `useReducer` 를 사용 할 때에는 코드를 어떻게 준비해줘야 하는지 알아봅시다.

### 카운터를 `useReducer` 로 다시 구현하기

우리가 아까 만들었던 Counter 컴포넌트를 `useState` 가 아닌 `useReducer` 로 사용하는 코드로 전환해보도록 하겠습니다.

#### src/Counter.tsx

```typescript
import React, { useReducer } from 'react';

type Action = { type: 'INCREASE' } | { type: 'DECREASE' }; // 이렇게 액션을 | 으로 연달아서 쭉 나열하세요.

function reducer(state: number, action: Action): number {
  switch (action.type) {
    case 'INCREASE':
      return state + 1;
    case 'DECREASE':
      return state - 1;
    default:
      throw new Error('Unhandled action');
  }
}

function Counter() {
  const [count, dispatch] = useReducer(reducer, 0);
  const onIncrease = () => dispatch({ type: 'INCREASE' });
  const onDecrease = () => dispatch({ type: 'DECREASE' });

  return (
    <div>
      <h1>{count}</h1>
      <div>
        <button onClick={onIncrease}>+1</button>
        <button onClick={onDecrease}>-1</button>
      </div>
    </div>
  );
}

export default Counter;
```

`Action` 부분을 보시면 다음과 같이 `|` 라는 문자를 사용했는데 이 문자는 OR 를 의미합니다.

```typescript
type Action = { type: 'INCREASE' } | { type: 'DECREASE' }; // 이렇게 액션을 | 으로 연달아서 쭉 나열하세요.
```

결국 위 코드는 Action 의 타입은 `{ type: 'INCREASE' }` 또는 `{ type: 'DECREASE' }` 라는 것을 명시해줍니다.

위 코드에 있는 `reducer` 함수의 맨 윗줄을 확인해봅시다.

```typescript
function reducer(state: number, action: Action): number 
```

보시면, `state`의 타입과 함수의 리턴 타입이 동일하지요? 리듀서를 만들 땐 이렇게 파라미터로 받아오는 상태의 타입과 함수가 리턴하는 타입을 동일하게 하는 것이 매우 중요합니다. 이렇게 리턴 타입을 상태와 동일한 타입으로 설정함으로써 실수들을 방지 할 수 있습니다. (예: 특정 케이스에 결과값을 반환하지 않았거나, 상태의 타입이 바뀌게 되었을 경우 에러를 감지해낼 수 있습니다.)

지금은 액션들이 `type` 값만 있어서 굉장히 간단한데요, 만약 액션 객체에 필요한 다른 값들이 있는 경우엔 다른 값들도 타입안에 명시를 해주면 추후 리듀서를 작성 할 때 액션 객체 안에 무엇이 들어있는지도 자동완성을 통해서 알 수 있습니다. 추가적으로, 새로운 액션을 디스패치 할 때에도 액션에 대한 타입스크립트 타입검사도 해줍니다.

### ReducerSample 구현하기

자동완성이 되는 것과 타입검사가 되는 것을 직접 확인해보기 위하여 ReducerSample 라는 컴포넌트를 만들어보도록 하겠습니다. src 디렉터리에 ReducerSample.tsx 라는 파일을 생성하고, 다음 코드를 쭉 따라서 작성해보세요. 코드를 작성하는 과정에서 코드가 자동완성이 되는 것도 볼 수 있을 것이고, 만약에 필요한 값을 빠뜨리면 에러가 발생 하는 것도 보실 수 있을 것입니다.

#### src/ReducerSample.tsx

```typescript
import React, { useReducer } from 'react';

type Color = 'red' | 'orange' | 'yellow';

type State = {
  count: number;
  text: string;
  color: Color;
  isGood: boolean;
};

type Action =
  | { type: 'SET_COUNT'; count: number }
  | { type: 'SET_TEXT'; text: string }
  | { type: 'SET_COLOR'; color: Color }
  | { type: 'TOGGLE_GOOD' };

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'SET_COUNT':
      return {
        ...state,
        count: action.count // count가 자동완성되며, number 타입인걸 알 수 있습니다.
      };
    case 'SET_TEXT':
      return {
        ...state,
        text: action.text // text가 자동완성되며, string 타입인걸 알 수 있습니다.
      };
    case 'SET_COLOR':
      return {
        ...state,
        color: action.color // color 가 자동완성되며 color 가 Color 타입인걸 알 수 있습니다.
      };
    case 'TOGGLE_GOOD':
      return {
        ...state,
        isGood: !state.isGood
      };
    default:
      throw new Error('Unhandled action');
  }
}

function ReducerSample() {
  const [state, dispatch] = useReducer(reducer, {
    count: 0,
    text: 'hello',
    color: 'red',
    isGood: true
  });

  const setCount = () => dispatch({ type: 'SET_COUNT', count: 5 }); // count 를 넣지 않으면 에러발생
  const setText = () => dispatch({ type: 'SET_TEXT', text: 'bye' }); // text 를 넣지 않으면 에러 발생
  const setColor = () => dispatch({ type: 'SET_COLOR', color: 'orange' }); // orange 를 넣지 않으면 에러 발생
  const toggleGood = () => dispatch({ type: 'TOGGLE_GOOD' });

  return (
    <div>
      <p>
        <code>count: </code> {state.count}
      </p>
      <p>
        <code>text: </code> {state.text}
      </p>
      <p>
        <code>color: </code> {state.color}
      </p>
      <p>
        <code>isGood: </code> {state.isGood ? 'true' : 'false'}
      </p>
      <div>
        <button onClick={setCount}>SET_COUNT</button>
        <button onClick={setText}>SET_TEXT</button>
        <button onClick={setColor}>SET_COLOR</button>
        <button onClick={toggleGood}>TOGGLE_GOOD</button>
      </div>
    </div>
  );
}

export default ReducerSample;
```

이렇게, 상태값이 객체로 이루어져 있고 안에 여러 타입의 값이 들어 있다면 위 코드에서 `State` 라는 타입을 만들었듯이 이에 대한 타입을 준비해주시면 좋습니다.

이번에 다룬 액션들은 `type`값만 있는 것이 아니라 `count`, `text`, `color` 같은 추가적인 값이 있습니다. 이러한 상황에서 `Action` 이라는 타입스크립트 타입을 정의함으로써 리듀서에서 자동완성이 되어 개발에 편의성을 더해주고, 액션을 디스패치하게 될 때에도 액션에 대한 타입검사가 이루어지므로 사소한 실수를 사전에 방지 할 수 있답니다.

이 컴포넌트를 App 에서 렌더링 한 다음에 각 버튼들을 눌러보세요. 상태가 잘 업데이트 되고 있나요?

#### App.tsx

```typescript
import React from 'react';
import ReducerSample from './ReducerSample';

const App: React.FC = () => {
  return <ReducerSample />;
};

export default App;
```

![img](https://i.imgur.com/h0sQne9.png)
![img](https://i.imgur.com/8t3aK0Y.png)

## useRef

`useRef`는 우리가 리액트 컴포넌트에서 외부 라이브러리의 인스턴스 또는 DOM 을 특정 값 안에 담을 때 사용합니다. 추가적으로, 이를 통해 컴포넌트 내부에서 관리하고 있는 값을 관리할 때 유용하죠. 단, 이 값은 렌더링과 관계가 없어야 합니다.

### 변수 값 관리하기

타입스크립트 환경에서 `useRef` 를 통해 어떤 변수 값을 관리하고 싶을 땐 다음과 같은 코드를 작성합니다.

```typescript
const id = useRef<number>(0);
  const increaseId = () => {
    id.current += 1;
  }
```

`useRef` 를 쓸땐 위와 같은 코드처럼 Generic 을 통해 `~.current` 의 값을 추론 할 수 있습니다.

### DOM 관리하기

ref 안에 DOM 을 담을 때도 마찬가지입니다. 단, 초깃값은 `null` 로 설정해주세요. 한번 MyForm 컴포넌트를 열어서, `handleSubmit` 이벤트가 등록 됐을 때 첫번째 인풋에 포커스가 잡히도록 수정을 해보겠습니다.

```typescript
import React, { useState, useRef } from 'react';

type MyFormProps = {
  onSubmit: (form: { name: string; description: string }) => void;
};

function MyForm({ onSubmit }: MyFormProps) {
  const inputRef = useRef<HTMLInputElement>(null);

  const [form, setForm] = useState({
    name: '',
    description: ''
  });

  const { name, description } = form;

  const onChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setForm({
      ...form,
      [name]: value
    });
  };

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    onSubmit(form);
    setForm({
      name: '',
      description: ''
    });
    if (!inputRef.current) {
      return;
    }
    inputRef.current.focus();
  };

  return (
    <form onSubmit={handleSubmit}>
      <input name="name" value={name} onChange={onChange} ref={inputRef} />
      <input name="description" value={description} onChange={onChange} />
      <button type="submit">등록</button>
    </form>
  );
}

export default MyForm;
```

`inputRef` 쪽 코드를 보면 다음과 같이 Generic 으로 `HTMLInputElement` 타입을 넣어주었습니다.

```typescript
 const inputRef = useRef<HTMLInputElement>(null);
```

추후 `ref`를 사용 할 때 어떤 타입을 써야 하지? 하고 헷갈릴 수 있을 것입니다. 그럴 땐, 에디터 상에서 커서를 원하는 DOM 위에 올려보세요.

![img](https://media.vlpt.us/post-images/velopert/814d85b0-e08e-11e9-a5d8-37f75617a124/image.png)

그러면, 어떤 타입을 써야 하는지 쉽게 알 수 있습니다. (위 이미지의 드래그 한 부분이 타입 이름)

추가적으로, `inputRef.current` 안의 값을 사용 하려면 `null` 체킹을 해주어야 합니다. 즉, 특정 값이 정말 유효한지 유효하지 않은지 체크하는건데요, 타입스크립트에서 만약 어떤 타입이 `undefined` 이거나 `null` 일 수 있는 상황에는, 해당 값이 유효한지 체킹하는 작업을 꼭 해주어야 자동완성도 잘 이루어지고, 오류도 사라집니다.

이제 App을 열어서 MyForm 컴포넌트를 렌더링해보세요.

```javascript
import React from 'react';
import MyForm from './MyForm';

const App: React.FC = () => {
  const onSubmit = (form: { name: string; description: string }) => {
    console.log(form);
  };
  return <MyForm onSubmit={onSubmit} />;
};

export default App;
```

이제 코드를 저장하시고 나면, 등록 버튼을 눌렀을때 첫번째 인풋에 포커스가 잡히는 것을 확인하실 수 있을 것입니다.

[![img](https://codesandbox.io/static/img/play-codesandbox.svg)](https://codesandbox.io/s/ts-react-tutorial-h9v3x?fontsize=14)

## 정리

이번 튜토리얼에서 배운 중요한 것들을 요약해보면 다음과 같습니다.

- `useState`를 사용 할 때에는 `useState` 과 같이 Generics 를 사용합니다.
- `useState`의 Generics 는 상황에 따라 생략 할 수도 있는데, 상태가 `null` 인 상황이 발생 할 수 있거나, 배열 또는 까다로운 객체를 다루는 경우 Generics 를 명시해야 합니다.
- `useReducer`를 사용 할 때에는 액션에 대한 타입스크립트 타입들을 모두 준비해서 `|` 문자를 사용하여 결합시켜야합니다.
- 타입스크립트 환경에서 `useReducer` 를 쓰면 자동완성이 잘되고 타입체킹도 잘 됩니다.
- `useRef`를 사용 할 땐 Generics 로 타입을 정합니다.
- `useRef`를 사용하여 DOM에 대한 정보를 담을 땐, 초깃값을 `null` 로 설정해야 하고 값을 사용하기 위해서 `null` 체킹도 해주어야 합니다.

다음 튜토리얼에서는 타입스크립트 환경에서 Context API 를 효율적으로 사용하는 방법에 대해서 다뤄보겠습니다.


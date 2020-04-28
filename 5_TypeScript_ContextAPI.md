# TypeScript 환경에서 리액트 Context API 제대로 활용하기



이번 튜토리얼에서는 타입스크립트 환경에서 Context API를 제대로 활용하는 방법에 대해서 다뤄보도록 하겠습니다. Context API를 사용함에 있어서, 코드의 구조를 어떻게 가져갈 지에 대해서는 딱 정해진 방법이 존재하지 않습니다. Context 를 준비하는 과정에서 클래스형 컴포넌트를 사용 할 수도 있고, 함수형 컴포넌트를 사용 할 수도 있죠. 함수형 컴포넌트를 사용 할 때에도 `useReducer`를 사용 할 수도 있고 `useState`를 사용 할 수도 있겠죠.

Context API를 활용하는 여러가지 방법 중에서, 제가 생각하기에 편하다고 생각하는 방식을 여러분께 소개시켜드리겠습니다.

> 이 튜토리얼에서 사용된 코드는 [Github Repo](https://github.com/vlpt-playground/typescript-react-context-todoapp) 에서 확인 할 수 있습니다.

## 프로젝트 준비

먼저, Context API를 연습해볼 타입스크립트가 적용된 리액트 프로젝트를 준비해주세요.

```bash
$ npx create-react-app ts-context-api-tutorial --typescript
```

우리는 Context API 를 활용하여 투두리스트를 만들어보겠습니다. Context API 를 활용하기 전에, 컴포넌트 몇가지를 미리 만들어볼건데요 앞으로 만들 컴포넌트들은 다음과 같습니다.

- **TodoForm.tsx**: 새 할 일을 등록할 때 사용
- **TodoItem.tsx**: 할 일에 대한 정보를 보여줌
- **TodoList.tsx**: 여러 TodoItem들을 렌더링해줌

src 디렉터리에 components 디렉터리를 만들고, 그 안에 위 컴포넌트들을 하나씩 하나씩 만들어보겠습니다.

#### src/components/TodoForm.tsx

TodoForm 컴포넌트는 새 항목을 등록 할 수 있는 컴포넌트입니다. 이 컴포넌트에서는 하나의 input과 하나의 button을 렌더링하세요. input의 value값은 `useState`를 통해서 관리하도록 하겠습니다. 추가적으로, submit 이벤트가 발생 했을 때는 새 항목을 생성하고 value값을 초기화 해줄건데요, 새 항목을 생성하는 부분은 추후 구현해주겠습니다.

```typescript
import React, { useState } from 'react';

function TodoForm() {
  const [value, setValue] = useState('');

  const onSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // TODO: 새 항목 생성하기
    setValue('');
  };

  return (
    <form onSubmit={onSubmit}>
      <input
        value={value}
        placeholder="무엇을 하실 건가요?"
        onChange={e => setValue(e.target.value)}
      />
      <button>등록</button>
    </form>
  );
}

export default TodoForm;
```

#### src/components/TodoItem.tsx

TodoItem 컴포넌트는 할 일 항목에 대한 정보를 보여주는 컴포넌트입니다. props 로는 `todo` 객체를 받아옵니다. 만약 `todo.done` 값이 참이라면 `done` CSS 클래스를 적용합니다.

```typescript
import React from 'react';
import './TodoItem.css';

export type TodoItemProps = {
  todo: {
    id: number;
    text: string;
    done: boolean;
  };
}

function TodoItem({ todo }: TodoItemProps) {
  return (
    <li className={`TodoItem ${todo.done ? 'done' : ''}`}>
      <span className="text">{todo.text}</span>
      <span className="remove">(X)</span>
    </li>
  );
}

export default TodoItem;
```

##### src/components/TodoItem.css

위 컴포넌트에 대한 CSS 파일도 작성해주세요.

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

이제 마지막 컴포넌트인 TodoList 컴포넌트를 작성해줍시다. 이 컴포넌트에서는 `todos` 라는 배열을 사용하여 여러개의 TodoItems 컴포넌트를 렌더링해주는 작업을 해줄건데요, 아직은 이 배열에 대한 상태가 존재하지 않으므로 이 배열을 임시적으로 TodoList 컴포넌트 내부에서 선언하도록 하겠습니다.

```typescript
import React from 'react';
import TodoItem from './TodoItem';

function TodoList() {
  const todos = [
    {
      id: 1,
      text: 'Context API 배우기',
      done: true
    },
    {
      id: 2,
      text: 'TypeScript 배우기',
      done: true
    },
    {
      id: 3,
      text: 'TypeScript 와 Context API 함께 사용하기',
      done: false
    }
  ];
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

#### src/App.tsx

이제 우리가 만든 컴포넌트를 App 에서 렌더링해봅시다.

```typescript
import React from 'react';
import TodoForm from './components/TodoForm';
import TodoList from './components/TodoList';

const App = () => {
  return (
    <>
      <TodoForm />
      <TodoList />
    </>
  );
};

export default App;
```

다음과 같은 결과가 나타났나요?
![img](https://media.vlpt.us/post-images/velopert/6ae78fb0-e2d6-11e9-b0e8-f9fda9e445c9/image.png)

## Context 준비하기

그럼 이제 본격적으로 Context API를 사용해봅시다. src 디렉터리에 contexts 디렉터리를 만들고, 그 안에 TodosContext.tsx 파일을 생성해보세요.

우리는 TodosContext.tsx 파일 안에 **두 개의 Context**를 만들어보도록 하겠습니다. 하나는 상태 전용 Context 이고, 또 다른 하나는 디스패치 전용 Context 입니다. 이렇게 두 개의 Context 를 만들면 낭비 렌더링을 방지 할 수 있습니다.

만약 상태와 디스패치 함수를 한 Context 에 넣게 된다면, TodoForm 컴포넌트처럼 상태는 필요하지 않고 디스패치 함수만 필요한 컴포넌트도 상태가 업데이트 될 때 리렌더링하게 됩니다. 두 개의 Context를 만들어서 관리한다면 이를 방지 할 수 있습니다.

### 상태전용 Context 만들기

먼저 상태전용 Context를 선언해보겠습니다.

#### src/contexts/TodosContext.tsx

```typescript
import { createContext } from 'react';

// 나중에 다른 컴포넌트에서 타입을 불러와서 쓸 수 있도록 내보내겠습니다.
export type Todo = {
  id: number;
  text: string;
  done: boolean;
};

type TodosState = Todo[];

const TodosStateContext = createContext<TodosState | undefined>(undefined);
```

Context 를 만들땐 위 코드와 같이 `createContext` 함수의 Generics 를 사용하여 Context에서 관리 할 값의 상태를 설정해줄 수 있는데요, 우리가 추후 Provider를 사용하지 않았을 때에는 Context의 값이 `undefined` 가 되어야 하므로, `` 와 같이 Context 의 값이 `TodosState` 일 수도 있고 `undefined` 일 수도 있다고 선언을 해주세요.

### 액션을 위한 타입 선언하기

그 다음엔, 액션들을 위한 타입스크립트 타입들을 선언해주세요. 우리는 총 3가지의 액션들을 만들 것입니다.

- **CREATE**: 새로운 항목 생성
- **TOGGLE**: done 값 반전
- **REMOVE**: 항목 제거

#### src/contexts/TodosContext.tsx

```typescript
import { createContext } from 'react';

export type Todo = {
  id: number;
  text: string;
  done: boolean;
};

type TodosState = Todo[];

const TodosStateContext = createContext<TodosState | undefined>(undefined);

type Action =
  | { type: 'CREATE'; text: string }
  | { type: 'TOGGLE'; id: number }
  | { type: 'REMOVE'; id: number };
```

이렇게 액션들의 타입을 선언해주고 나면, 우리가 디스패치를 위한 Context를 만들 때 디스패치 함수의 타입을 설정 할 수 있게 됩니다.

#### src/contexts/TodosContext.tsx

```typescript
import { createContext, Dispatch } from 'react';

export type Todo = {
  id: number;
  text: string;
  done: boolean;
};

type TodosState = Todo[];

const TodosStateContext = createContext<TodosState | undefined>(undefined);

type Action =
  | { type: 'CREATE'; text: string }
  | { type: 'TOGGLE'; id: number }
  | { type: 'REMOVE'; id: number };

type TodosDispatch = Dispatch<Action>;
const TodosDispatchContext = createContext<TodosDispatch | undefined>(
  undefined
);
```

이렇게 `Dispatch` 를 리액트 패키지에서 불러와서 Generic으로 액션들의 타입을 넣어주면 추후 컴포넌트에서 액션을 디스패치 할 때 액션들에 대한 타입을 검사 할 수 있습니다. 예를 들어서, 액션에 추가적으로 필요한 값 (예: `text`, `id`)이 빠지면 오류가 발생하죠.

### 리듀서 작성하기

이제 할 일 관리를 위한 리듀서를 만들어봅시다!

#### src/contexts/TodosContext.tsx

```typescript
import { createContext, Dispatch } from 'react';

export type Todo = {
  id: number;
  text: string;
  done: boolean;
};

type TodosState = Todo[];

const TodosStateContext = createContext<TodosState | undefined>(undefined);

type Action =
  | { type: 'CREATE'; text: string }
  | { type: 'TOGGLE'; id: number }
  | { type: 'REMOVE'; id: number };

type TodosDispatch = Dispatch<Action>;
const TodosDispatchContext = createContext<TodosDispatch | undefined>(
  undefined
);

function todosReducer(state: TodosState, action: Action): TodosState {
  switch (action.type) {
    case 'CREATE':
      const nextId = Math.max(...state.map(todo => todo.id)) + 1;
      return state.concat({
        id: nextId,
        text: action.text,
        done: false
      });
    case 'TOGGLE':
      return state.map(todo =>
        todo.id === action.id ? { ...todo, done: !todo.done } : todo
      );
    case 'REMOVE':
      return state.filter(todo => todo.id !== action.id);
    default:
      throw new Error('Unhandled action');
  }
}
```

이렇게 타입스크립트를 사용하여 리듀서를 작성하는 과정에서는 다음과 같이 액션의 `type` 값이 자동완성도 되고

![img](https://media.vlpt.us/post-images/velopert/7b8e4f70-e2db-11e9-90ac-878e1d98da7f/image.png)

액션의 `type`에 따라 그 액션 객체의 구조가 어떻게 구성되었는지도 바로 IDE상에서 알 수 있습니다.

![img](https://media.vlpt.us/post-images/velopert/a9bd6e30-e2db-11e9-a0b9-5f1d4b321db5/image.png)

### TodosProvider 만들기

이제 TodosStateContext와 TodosDispatchContext의 Provider를 함께 사용하는 TodosProvider 라는 컴포넌트를 준비해보겠습니다.

```typescript
import React, { createContext, Dispatch, useReducer } from 'react';

(...) // (이전 코드 생략)

export function TodosContextProvider({ children }: { children: React.ReactNode }) {
  const [todos, dispatch] = useReducer(todosReducer, [
    {
      id: 1,
      text: 'Context API 배우기',
      done: true
    },
    {
      id: 2,
      text: 'TypeScript 배우기',
      done: true
    },
    {
      id: 3,
      text: 'TypeScript 와 Context API 함께 사용하기',
      done: false
    }
  ]);

  return (
    <TodosDispatchContext.Provider value={dispatch}>
      <TodosStateContext.Provider value={todos}>
        {children}
      </TodosStateContext.Provider>
    </TodosDispatchContext.Provider>
  );
}
```

우리가 방금 만든 컴포넌트는 나중에 App 에서 불러와서 기존 내용을 감싸주어야 하므로 내보내주셔야합니다.

자, 이제 Context준비는 거의 다 끝났습니다.

### 커스텀 Hooks 두 개 작성하기

우리가 추후 TodosStateContext와 TodosDispatchContext를 사용하게 될 때는 다음과 같이 `useContext`를 사용해서 Context 안의 값을 사용 할 수 있습니다.

```typescript
const todos = useContext(TodosStateContext);
```

그런데 이 때 `todos` 의 타입은 `TodosState | undefined` 일 수 도 있습니다. 따라서, 해당 배열을 사용하기 전에 꼭 해당 값이 유효한지 확인을 해주어야 하죠.

```typescript
const todos = useContext(TodosStateContext);
if (!todo) return null;
```

그렇게 해도 상관은 없지만.. 더 좋은 방법은 TodosContext 전용 Hooks를 작성해서 조금 더 편리하게 사용하는 것 입니다. 다음과 같이 코드를 작성하면 추후 상태 또는 디스패치를 더욱 편하게 이용 할 수도 있고, 컴포너트에서 사용 할 때 유효성 검사도 생략 할 수 있습니다.

커스텀 Hooks 를 작성해봅시다.

#### src/contexts/TodosContext.tsx

```typescript
import React, { createContext, Dispatch, useReducer, useContext } from 'react';

(...)
 
export function useTodosState() {
  const state = useContext(TodosStateContext);
  if (!state) throw new Error('TodosProvider not found');
  return state;
}

export function useTodosDispatch() {
  const dispatch = useContext(TodosDispatchContext);
  if (!dispatch) throw new Error('TodosProvider not found');
  return dispatch;
}
```

이렇게 만약 함수 내부에서 필요한 값이 유효하지 않다면 에러를 `throw` 하여 각 Hook이 반환하는 값의 타입은 언제나 유효하다는 것을 보장 받을 수 있습니다. (만약 유효하지 않다면 브라우저의 콘솔에 에러가 바로 나타납니다.)

이제 Context 작성이 드디어 모두 끝났습니다. `useTodosState`와 `useTodosDispatch`는 다른 컴포넌트에서 불러와서 사용 할 수 있도록 내보내주셔야 합니다.

## 컴포넌트에서 Context 사용하기

이제 우리가 만든 Context 를 사용해줄 차례입니다.

### TodosContextProvider로 감싸기

가장 먼저 해야 할 작업은 App 컴포넌트에서 TodosContextProvider 를 불러와서 기존 내용을 감싸주는 것 입니다.

#### src/App.tsx

```typescript
import React from 'react';
import TodoForm from './components/TodoForm';
import TodoList from './components/TodoList';
import { TodosContextProvider } from './contexts/TodosContext';

const App = () => {
  return (
    <TodosContextProvider>
      <TodoForm />
      <TodoList />
    </TodosContextProvider>
  );
};

export default App;
```

### TodoList 에서 상태 조회하기

그 다음에는 TodoList 컴포넌트에서 Context 안의 상태를 조회하여 내용을 렌더링해보겠습니다. 우리가 커스텀 Hook을 만들었기 때문에 정말로 간단하게 처리 할 수 있답니다.

#### src/components/TodoList.tsx

```javascript
import React from 'react';
import TodoItem from './TodoItem';
import { useTodosState } from '../contexts/TodosContext';

function TodoList() {
  const todos = useTodosState();
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

그냥 `useTodosState` 를 불러와서 호출하기만 하면 현재 상태를 조회 할 수 있답니다.

### TodoForm 에서 새 항목 등록하기

이제 TodoForm 에서 새 항목을 등록하는 작업을 구현해봅시다. `useTodosDispatch` Hook 을 통해 `dispatch` 함수를 받아오고, 액션을 디스패치해보세요.

#### src/components/TodoForm.tsx

```typescript
import React, { useState } from 'react';
import { useTodosDispatch } from '../contexts/TodosContext';

function TodoForm() {
  const [value, setValue] = useState('');
  const dispatch = useTodosDispatch();

  const onSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    dispatch({
      type: 'CREATE',
      text: value
    });
    setValue('');
  };

  return (
    <form onSubmit={onSubmit}>
      <input
        value={value}
        placeholder="무엇을 하실 건가요?"
        onChange={e => setValue(e.target.value)}
      />
      <button>등록</button>
    </form>
  );
}

export default TodoForm;
```

액션을 디스패치하는 코드를 작성하는 과정에서, 액션의 `type` 이 자동완성도 되고, 액션에 필요한 값이 빠져있다면 타입검사를 통해 오류를 보여줍니다.

![img](https://media.vlpt.us/post-images/velopert/d50eba00-e2de-11e9-90ac-878e1d98da7f/image.png)
![img](https://media.vlpt.us/post-images/velopert/1931a8a0-e2df-11e9-b714-2f4cb004a6a6/image.png)

여기까지 코드를 다 작성하셨으면, 새로운 항목이 정말 잘 등록되는지 직접 입력을 해서 등록을 해보세요.

![img](https://media.vlpt.us/post-images/velopert/91de7350-e2df-11e9-b714-2f4cb004a6a6/image.png)

### TodoItem 에서 항목 토글 및 제거하기

이번에는 TodoItem 에서 항목을 클릭했을 때 `done` 값을 토글하고, 우측의 (X) 를 눌렀을 때 제거하는 기능을 구현해보겠습니다. 아마 일반적으로 Context를 사용하지 않는 환경에서는 TodoItem 컴포넌트에서 `onToggle`, `onRemove` props 를 가져와서 이를 호출하는 형태로 구현 할 것 입니다. 하지만 지금과 같이 Context를 사용하고 있다면 굳이 이 함수들을 props를 통해서 가져오지 않고, 이 컴포넌트 내부에서 바로 액션을 디스패치하는 것도 꽤나 괜찮은 방법입니다.

#### src/components/TodoItem.tsx

```typescript
import React from 'react';
import './TodoItem.css';
import { useTodosDispatch, Todo } from '../contexts/TodosContext';

type TodoItemProps = {
  todo: Todo; // TodoContext 에서 선언했던 타입을 불러왔습니다.
};

function TodoItem({ todo }: TodoItemProps) {
  const dispatch = useTodosDispatch();

  const onToggle = () => {
    dispatch({
      type: 'TOGGLE',
      id: todo.id
    });
  };

  const onRemove = () => {
    dispatch({
      type: 'REMOVE',
      id: todo.id
    });
  };

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

이제 TodoItem 의 구현도 모두 끝났습니다! 브라우저에서 TodoItem 항목의 `done` 상태를 토글도 해보고, 항목을 삭제도 해보세요.

## 정리

이번 튜토리얼에서는 우리가 타입스크립트 환경에서 리액트의 Context API를 효과적으로 활용하는 방법에 대해서 알아보았습니다. Context API를 사용하여 상태를 관리 할 때 `useReducer`를 사용하고 상태 전용 Context 와 디스패치 함수 전용 Context를 만들면 매우 유용합니다. 추가적으로, Context를 만들고 나서 해당 Context를 쉽게 사용 할 수 있는 커스텀 Hooks를 작성하면 더욱 편하게 개발을 하실 수 있습니다.

이 튜토리얼에서 사용하는 방식은 꽤나 편한 방식이지만 무조건 정답은 아닙니다. 더 개선할 점이 있거나, 여러분만의 노하우가 있으면 소개시켜주세요~


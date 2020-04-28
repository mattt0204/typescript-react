#  리액트 컴포넌트 타입스크립트로 작성

## 프로젝트생성

우선, 타입스크립트를 사용하는 리액트 프로젝트를 만들어볼까요?

타입스크립트를 사용하는 리액트 프로젝트를 만들때는 다음과 같이 명령어를 사용하세요.

```bash
$ npx create-react-app ts-react-tutorial --typescript

npx create-react-app [폴더명] --template typescript
# or
yarn create react-app [폴더명] --template typescript
```

위와 같이 뒤에 `--typescript` 가 있으면 타입스크립트 설정이 적용된 프로젝트가 생성된답니다.
만약, 이미 만든 프로젝트에 타입스크립트를 적용하고 싶으시다면 이 [링크](https://create-react-app.dev/docs/adding-typescript)를 확인해주세요.

> 에디터를 사용 할 수 없는 환경이시라면 Codesandbox 의 [react-ts](https://codesandbox.io/s/react-ts) 샌드박스를 사용 하시는 것을 추천합니다.

이제 프로젝트를 열어보시면 src 디렉터리 안에 App.tsx 라는 파일이 있을것입니다. 타입스크립트를 사용하는 리액트 컴포넌트는 이와 같이 `*.tsx` 확장자를 사용한답니다. 해당 파일을 한번 열어볼까요?

#### App.tsx

```typescript
import React from 'react';
import logo from './logo.svg';
import './App.css';

const App: React.FC = () => {
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.tsx</code> and save to reload.
        </p>
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React
        </a>
      </header>
    </div>
  );
}

export default App;
```

이 컴포넌트를 보시면, `const App: React.FC = () => { ... }` 와 같이 화살표함수를 사용하여 컴포넌트가 선언되었습니다. 그런데, 꼭 화살표 함수를 사용하여 선언 할 필요는 없습니다. 요새 해외의 유명 개발자 분들([링크1](https://overreacted.io/a-complete-guide-to-useeffect/), [링크2](https://kentcdodds.com/blog/how-to-use-react-context-effectively))은 보통 `function` 키워드를 사용하여 함수형 컴포넌트를 선언하는 것으로 추세 입니다. 리액트 공식 매뉴얼에서도 `function` 키워드를 사용하고 있기도 하죠.

반면 프로젝트를 만들 때 자동생성 된 App.tsx 의 경우 `React.FC` 라는 타입을 사용하여 화살표 함수를 사용하면서 컴포넌트를 선언했는데요, 이렇게 타입하는 것이 좋을수도 있고 나쁠 수도 있습니다. 저는 나쁘다고 생각합니다. 이유는 계속 읽으시다 보면 알 게 될 것입니다.

> 저는 옛날에 함수형 컴포넌트 선언 할 때 화살표 함수를 사용해왔었는데요, 요즘은 `function` 키워드를 사용해가고 있습니다. 최근 리액트를 다루는 기술 개정판에서도 화살표 함수로 선언했었는데.. 내년 개정판쯤에는 `function` 으로 통일을 하게 될 것 같네요!

한번, 새로운 컴포넌트를 직접 작성해보면서 `React.FC` 를 사용하는 것과 사용하지 않는 것의 차이를 알아보도록 하겠습니다.

## 새로운 컴포넌트 만들기

Greetings라는 새로운 컴포넌트를 작성해봅시다. src 디렉터리에 다음 파일을 생성 후 작성해보세요.

#### src/Greetings.tsx

```typescript
import React from 'react';

type GreetingsProps = {
  name: string;
};

const Greetings: React.FC<GreetingsProps> = ({ name }) => (
  <div>Hello, {name}</div>
);

export default Greetings;
```

컴포넌트의 props 에 대한 타입을 선언 할 때에는 `type` 을 써도 되고, `interface`를 써도 됩니다. 여러분의 자유이기 때문에, 마음대로 하셔도 되는데, 프로젝트에서 일관성만 유지하시면 됩니다. (A 에서는 `interface` 쓰고 B에서는 `type` 쓰고 이런건 지양해야 한다는 말 입니다.)

### React.FC 의 장단점

`React.FC` 를 사용 할 때는 props 의 타입을 Generics 로 넣어서 사용합니다. 이렇게 `React.FC`를 사용해서 얻을 수 있는 이점은 두가지가 있습니다.

첫번째는, props 에 기본적으로 `children` 이 들어가있다는 것 입니다.

![img](https://i.imgur.com/hmQz26Q.png)

> 중괄호 안에서 Ctrl + Space 를 눌러보면 확인 할 수 있습니다.

두번째는 컴포넌트의 defaultProps, propTypes, contextTypes 를 설정 할 때 자동완성이 될 수 있다는 것 입니다.

![img](https://i.imgur.com/SxdC0x0.png)

한편으로는 단점도 존재하긴 합니다. `children` 이 옵셔널 형태로 들어가있다보니까 어찌 보면 컴포넌트의 props 의 타입이 명백하지 않습니다. 예를 들어 어떤 컴포넌트는 `children`이 무조건 있어야 하는 경우도 있을 것이고, 어떤 컴포넌트는 `children` 이 들어가면 안되는 경우도 있을 것입니다. 결국 그에 대한 처리를 하고 싶다면 Props 타입 안에 `children` 을 명시해야하죠.

예를 들자면 다음과 같습니다.

```typescript
type GreetingsProps = {
  name: string;
  children: React.ReactNode;
};
```

결국 React.FC 에 `children` props 가 기본적으로 들어있는건 어찌보면 장점이 아닙니다. 차라리, `React.FC` 를 사용하지 않고 GreetingsProps 타입을 통해 `children`이 있다 없다를 명백하게 명시하는게 덜 헷갈립니다.

추가적으로, (아직까지는) `React.FC`를 사용하는 경우`defaultProps` 가 제대로 작동하지 않습니다. 이는 정말 치명적입니다. 한번 확인해볼까요? 예를 들어서 다음과 같이 코드를 작성 했다고 가정해봅시다.

#### src/Greetings.tsx

```typescript
import React from 'react';

type GreetingsProps = {
  name: string;
  mark: string;
};

const Greetings: React.FC<GreetingsProps> = ({ name, mark }) => (
  <div>
    Hello, {name} {mark}
  </div>
);

Greetings.defaultProps = {
  mark: '!'
};

export default Greetings;
```

그리고 App 에서 해당 컴포넌트를 렌더링한다면

#### src/App.tsx

```typescript
import React from 'react';
import Greetings from './Greetings';

const App: React.FC = () => {
  return <Greetings name="Hello" />;
};

export default App;
```

![img](https://i.imgur.com/cHzXsu4.png)

`mark` 를 `defaultProps` 로 넣었음에도 불구하고 `mark`값이 없다면서 제대로 작동하지 않습니다.

`React.FC`를 쓰면서 `defaultProps` 를 사용하려면 결국 코드를 다음과 같이 작성하는 수 밖에 없습니다.

#### src/Greetings.tsx

```typescript
import React from 'react';

type GreetingsProps = {
  name: string;
  mark: string;
};

const Greetings: React.FC<GreetingsProps> = ({ name, mark = '!' }) => (
  <div>
    Hello, {name} {mark}
  </div>
);

// 결국 무의미해진 defaultProps?
Greetings.defaultProps = {
  mark: '!' 
};

export default Greetings;
```

바로, 위와 같이 비구조화 할당을 하는 과정에서 기본값을 설정해주는거죠. 이렇게 하면 아래에 있는 `defaultProps`는 참 무의미해집니다..

반면, 만약 `React.FC` 를 생략하면 어떻게 될까요?

#### src/Greetings.tsx

```typescript
import React from 'react';

type GreetingsProps = {
  name: string;
  mark: string;
};

const Greetings = ({ name, mark }: GreetingsProps) => (
  <div>
    Hello, {name} {mark}
  </div>
);

Greetings.defaultProps = {
  mark: '!'
};

export default Greetings;
```

`React.FC`를 생략하면, 오히려 아주 잘 작동합니다! 이러한 이슈 때문에 `React.FC` 를 사용하지 말라는 [팁](https://medium.com/@martin_hotell/10-typescript-pro-tips-patterns-with-or-without-react-5799488d6680#78b9)도 존재합니다. 이를 쓰고 안쓰고는 여러분의 자유이지만, 저는 사용하지 않는 것을 권장합니다.

취향에 따라 화살표 함수도 만약 사용하지 않는다면 다음과 같은 형태가 됩니다.

#### src/Greetings.tsx

```typescript
import React from 'react';

type GreetingsProps = {
  name: string;
  mark: string;
};

function Greetings({ name, mark }: GreetingsProps) {
  return (
    <div>
      Hello, {name} {mark}
    </div>
  );
}

Greetings.defaultProps = {
  mark: '!'
};

export default Greetings;
```

화살표 함수를 쓸 지, `function` 키워드를 사용해서 선언을 할 지는 여러분의 자유입니다! 다만, `React.FC` 의 사용은 아직까지는 저는 권장하지 않습니다. 언젠간 이 이슈가 해결되리라 생각합니다.

### 컴포넌트에 생략 할 수 있는 props 설정하기

만약에 컴포넌트의 props 중에서 생략해도 되는 값이 있다면 `?` 문자를 사용하시면 됩니다. 다음과 같이 말이죠.

#### src/Greetings.tsx

```typescript
import React from 'react';

type GreetingsProps = {
  name: string;
  mark: string;
  optional?: string;
};

function Greetings({ name, mark, optional }: GreetingsProps) {
  return (
    <div>
      Hello, {name} {mark}
      {optional && <p>{optional}</p>}
    </div>
  );
}

Greetings.defaultProps = {
  mark: '!'
};

export default Greetings;
```

### 컴포넌트에서 함수 타입의 props 받아오기

만약 이 컴포넌트에서 특정 함수를 props 로 받아와야 한다면 다음과 같이 타입을 지정 할 수 있답니다.

#### src/Greetings.tsx

```typescript
import React from 'react';

type GreetingsProps = {
  name: string;
  mark: string;
  optional?: string;
  onClick: (name: string) => void; // 아무것도 리턴하지 않는다는 함수를 의미합니다.
};

function Greetings({ name, mark, optional, onClick }: GreetingsProps) {
  const handleClick = () => onClick(name);
  return (
    <div>
      Hello, {name} {mark}
      {optional && <p>{optional}</p>}
      <div>
        <button onClick={handleClick}>Click Me</button>
      </div>
    </div>
  );
}

Greetings.defaultProps = {
  mark: '!'
};

export default Greetings;
```

그러면, App 에서 해당 컴포넌트를 사용해야 할 때 다음과 같이 작성해야겠지요.

#### src/App.js

```typescript
import React from 'react';
import Greetings from './Greetings';

const App: React.FC = () => {
  const onClick = (name: string) => {
    console.log(`${name} says hello`);
  };
  return <Greetings name="Hello" onClick={onClick} />;
};

export default App;
```

제 `yarn start`를 해서 잘 작동하는지 확인해보세요. 버튼도 눌러보시고 콘솔에 메시지가 잘 출력되는지도 확인해보세요.

![img](https://i.imgur.com/kvHMUf2.png)

TypeScript 를 사용하신다면 만약 여러분이 컴포넌트를 렌더링 할 때 필요한 props 를 빠뜨리게 된다면 다음과 같이 에디터에 오류가 나타나게 됩니다.

![img](https://i.imgur.com/xXF6lrj.png)

그리고 만약 컴포넌트를 사용하는 과정에서 이 컴포넌트에서 무엇이 필요했더라? 하고 기억이 안날때는 단순히 커서를 컴포넌트 위에 올려보시거나, 컴포넌트의 props 를 설정하는 부분에서 Ctrl + Space 를 눌러보시면 됩니다.

![img](https://i.imgur.com/BmfsA3j.png)

이제, 여러분들은 함수형 컴포넌트를 타입스크립트로 작성하는 기본적인 방법을 배우셨습니다.

## 정리

이번 섹션에서 배웠던 것들을 요약하보자면, 다음과 같습니다.

- `React.FC` 는 별로 좋지 않다.
- 함수형 컴포넌트를 작성 할 때는 화살표 함수로 작성해도 되고, `function` 키워드를 사용해도 된다.
- Props 에 대한 타입을 선언 할 땐 `interface` 또는 `type` 을 사용하면 되며, 프로젝트 내부에서 일관성만 지키면 된다.

자, 그럼 다음 섹션에서는 상태관리를 하는 방법도 알아보도록 하겠습니다.




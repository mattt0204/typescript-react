# TypeScript 기초 실습

## 앞으로 이 시리즈에서 다룰 내용

이 시리즈를 진행하기 전에, TypeScript를 이미 잘 알고있다면 참 좋겠지만, 그렇지 않은 독자분들께서도 쉽게 타입스크립트에 입문하고 리액트 프로젝트에 적용 할 수 있도록 리액트에서 TypeScript를 활용하기 위해 핊요한 기본기를 가볍게 다룹니다. 이 튜토리얼에서는 모든 기능을 세세하게 다루진 않기 때문에 TypeScript를 꼼꼼하게 배워보고 싶다면 다음 링크를 참고해보세요.

- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/basic-types.html)
- [TypeScript Handbook 한글 문서](https://typescript-kr.github.io/)

먼저 타입스크립트의 기본기를 배우고 난 다음에는 타입스크립트가 적용된 리액트 프로젝트를 만들고, 컴포넌트를 작성 할 때 타입스크립트로 작성하는 방법에 대해서 다뤄보게 됩니다.

이 튜토리얼에서는 클래스형 컴포넌트를 타입스크립트를 작성하는 것에 대해서 다루지 않습니다. 따라서, 나중에 클래스 컴포넌트를 작성하는 방법을 알아보시려면 이 [링크](https://github.com/typescript-cheatsheets/react-typescript-cheatsheet#class-components)를 참고하세요. 클래스 컴포넌트를 다루지 않는 이유는 앞으로 여러분도, 저도 클래스 컴포넌트를 사용 할 일이 별로 없을거라고 생각하기 때문이고 글을 쓰는 것 또한 불필요한 리소스라고 생각하기 때문입니다.

이 튜토리얼에서는 함수형 컴포넌트와, Hooks 를 사용하는 것에 집중합니다. 따라서, 우리는 TypeScript 환경에서 `useState` 또는 `useReducer` 를 사용하여 상태관리를 하는 방법을 배우겠습니다.

추가적으로, 글로벌 상태관리를 할 때를 대비하여 Context API를 활용하는 방법도 빠질 수 없죠. 효율적으로 TypeScript와 Context API 를 사용하는 방법 또한 다뤄보게 됩니다.

그리고 리덕스를 다루는 방법도 배워 볼 것이구요, `typesafe-actions` 라는 라이브러리를 사용하여 정말 깔끔하게 액션 생성함수와 리듀서를 작성하는 방법도 배워볼겁니다. 그리고, 제가 요즘 좋아하는 리덕스 모듈의 디렉터리 구조도 소개시켜드릴게요.

마지막으로, 리덕스 미들웨어를 사용하는 방법도 다뤄볼것입니다. 이 때 우리는 redux-thunk 와 redux-saga 를 사용해보게 됩니다.



이 포스트에서는 여러분들이 타입스크립트를 리액트 프로젝트에서 사용해보기 전에, 알아두면 유용한 타입스크립트의 기초 핵심을 다뤄보게 됩니다. 추후 리액트를 사용할 것이 아니더라 하더라도, 이 튜토리얼에 나와있는 연습을 진행해보시면 타입스크립트를 통해 어떤 도움을 얻을 수 있는지 갈피를 잡을 수 있게 되어 입문에 도움이 될 거예요.

> 이 튜토리얼에서는 리액트 프로젝트에서 타입스크립트를 사용하기 위해서 필수적으로 알아야 하는 것들을 위주로 다뤄보게 됩니다. 이 튜토리얼에서 다루지 않는 기능도 많으니 추후 다음 링크를 참조해보시는 것을 권장드립니다.
>
> - [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/basic-types.html)
> - [TypeScript Handbook 한글 문서](https://typescript-kr.github.io/)
>
> 다만 위 링크에 있는 모든 정보들을 꼭 먼저 학습이 될 필요는 없습니다.
> 최대한 일찍 타입스크립트를 접하시고, 사용하시면서 배워가시면 충분합니다 (저도 그렇게 시작했답니다).

## 환경 준비

타입스크립트를 연습해볼 수 있는 환경을 준비해봅시다.

> 만약 여러분이 인터넷 브라우저만 쓸 수 있는 환경이라면 [CodeSandbox 의 ts-vanilla 샌드박스](https://codesandbox.io/s/vanilla-ts)를 사용하시는 것을 권장드립니다. src/index.ts 파일을 수정해보시고, 결과를 확인 할 때는 우측 하단의 Console 을 확인해보시면 됩니다.

먼저 새로운 타입스크립트 프로젝트를 생성해봅시다.

```bash
$ mkdir ts-practice
$ cd ts-practice
$ yarn init -y # 또는 npm init -y
```

이렇게 하면 ts-practice 디렉터리에 package.json 이라는 파일이 생성됩니다.

### 타입스크립트 설정파일 생성하기 ( 이 부분 안된다.)

그 다음에는 타입스크립트 설정파일 tsconfig.json 을 만들어봅시다. 다음과 같이 프로젝트 디렉터리에 tsconfig.json 파일을 생성 후 직접 작성을 해도 되는데요,

```json
{
  "compilerOptions": {
    "target": "es5",
    "module": "commonjs",
    "strict": true,
    "esModuleInterop": true
  }
}
```

그 대신에 우리는 명령어를 사용해서 생성하는 방법을 알아보겠습니다. 명령어를 사용해서 생성하는 방법은 다음과 같습니다. 먼저 typescript 를 글로벌로 설치를 해주어야 합니다.

```bash
$ yarn global add typescript # 또는 npm install -g typescript
```

그 다음에 프로젝트 디렉터리에서 다음 명령어를 명령어를 입력하면 tsconfig.json 파일이 자동생성됩니다.

```null
$ npm install tsc-init -g
```

> 글로벌 설치가 싫으시다면 다음 명령어를 입력해도 된답니다.
>
> ```null
> $ npx tsc --init
> ```

tsconfig.json 파일에서는 타입스크립트가 컴파일 될 때 필요한 옵션을 지정합니다. 명령어를 통해서 생성한 설정파일에 기본적으로 설정되어있는 속성들이 어떤 의미를 갖고 있는지 한번 알아볼까요?

- **target**: 컴파일된 코드가 어떤 환경에서 실행될 지 정의합니다. 예를들어서 화살표 함수를 사용하고 target 을 es5 로 한다면 일반 function 키워드를 사용하는 함수로 변환을 해줍니다. 하지만 이를 es6 로 설정한다면 화살표 함수를 그대로 유지해줍니다.
- **module**: 컴파일된 코드가 어던 모듈 시스템을 사용할지 정의합니다. 예를 들어서 이 값을 common 으로 하면 `export default Sample` 을 하게 됐을 때 컴파일 된 코드에서는 `exports.default = helloWorld` 로 변환해주지만 이 값을 es2015 로 하면 `export default Sample` 을 그대로 유지하게 됩니다.
- **strict**: 모든 타입 체킹 옵션을 활성화한다는 것을 의미합니다.
- **esModuleInterop**: commonjs 모듈 형태로 이루어진 파일을 es2015 모듈 형태로 불러올 수 있게 해줍니다. [(참고)](https://stackoverflow.com/questions/56238356/understanding-esmoduleinterop-in-tsconfig-file)

현재 기본적으로 만들어진 설정에서 한가지 속성을 추가해봅시다. `outDir` 이라는 속성인데요, 이를 설정하면 컴파일된 파일들이 저장되는 경로를 지정 할 수 있습니다.

```javascript
{
  "compilerOptions": {
    "target": "es5",
    "module": "commonjs",
    "strict": true,
    "esModuleInterop": true,
    "outDir": "./dist"
  }
}
```

### 타입스크립트 파일 만들기

프로젝트에 src 디렉터리를 만들고 그 안에 practice.ts 파일을 작성해보세요.

#### src/practice.ts

```typescript
const message: string = 'hello world';
console.log(message);
```

타입스크립트는 이렇게 `*.ts` 확장자를 사용합니다. message 값이 선언된 코드를 보시면 `: string` 이라는 코드를 넣었지요? 이는 해당 상수 값이 문자열 이라는 것을 명시해줍니다.

만약에 해당 값을 숫자로 설정해버리게 된다면 에디터 상에서 오류가 나타나게 됩니다.

![img](https://i.imgur.com/ehAqT3S.png)

코드를 모두 작성하셨으면 해당 프로젝트의 디렉터리에 위치한 터미널에서 `tsc` 명령어를 입력해보세요. (또는 `npx tsc`)

그러면 dist/practice.js 경로에 다음과 같이 파일이 생성될 것입니다.

```javascript
"use strict";
var message = 'hello world';
console.log(message);
```

우리가 ts 파일에서 명시한 값의 타입은 컴파일이 되는 과정에서 모두 사라지게 된답니다.

우리는 방금 글로벌로 설치한 타입스크립트 CLI 를 통해 코드를 컴파일 했는데요, 만약 프로젝트 내에 설치한 `typescript` 패키지를 사용하여 컴파일 하고 싶을 땐 다음과 같은 작업을 따라주어야 합니다 (공부 할 때는 상관 없는데 보통 일반적으로 타입스크립트를 사용하는 프로젝트들은 로컬로 설치한 `typescript` 패키지를 사용해서 컴파일합니다.)

다음 명령어를 사용하여 `typescript`를 로컬 패키지로 설치를 해주세요.

```bash
$ yarn add typescript # 또는 npm install --save typescript
```

그 다음에는 package.json 파일을 열어서 다음과 같이 `build` 스크립트를 만들고

```js
{
  "name": "ts-practice",
  "version": "1.0.0",
  "main": "index.js",
  "license": "MIT",
  "dependencies": {
    "ts-node": "^8.4.1",
    "typescript": "^3.6.3"
  },
  "scripts": {
    "build": "tsc"
  }
}
```

추후 빌드를 할 때 `yarn build` 라고 입력하시면 됩니다. (또는 `npm run build`)

이제, 타입스크립트를 사용할 준비가 끝났습니다. 본격적으로 사용해봅시다!

## 기본 타입

`let` 과 `const` 를 사용하여 특정 값을 선언 할 때 여러가지 기본 타입을 지정하여 선언하는 것을 연습해볼까요?

다음 코드를 한번 따라 작성해보세요.

#### src/practice.ts

```javascript
let count = 0; // 숫자
count += 1;
count = '갑자기 분위기 문자열'; // 이러면 에러가 납니다!

const message: string = 'hello world'; // 문자열

const done: boolean = true; // 불리언 값

const numbers: number[] = [1, 2, 3]; // 숫자 배열
const messages: string[] = ['hello', 'world']; // 문자열 배열

messages.push(1); // 숫자 넣으려고 하면.. 안된다!

let mightBeUndefined: string | undefined = undefined; // string 일수도 있고 undefined 일수도 있음
let nullableNumber: number | null = null; // number 일수도 있고 null 일수도 있음

let color: 'red' | 'orange' | 'yellow' = 'red'; // red, orange, yellow 중 하나임
color = 'yellow';
color = 'green'; // 에러 발생!
```

![img](https://i.imgur.com/ZzDrLr9.png)

타입스크립트를 사용하면 이렇게 특정 변수 또는 상수의 타입을 지정 할 수 있고 우리가 사전에 지정한 타입이 아닌 값이 설정 될 때 바로 에러를 발생시킵니다.

이렇게 에러가 나타났을땐 컴파일이 되지 않습니다. 한번 `tsc` 명령어를 입력해서 컴파일을 하려고 하면 다음과 같이 실패할것입니다.

![img](https://i.imgur.com/gC6VJWX.png)

> 기본 타입에 대한 더 자세한 알아보기 [(링크)](https://typescript-kr.github.io/pages/Basic Types.html)

## 함수에서 타입 정의하기

이번에는 함수에서 타입을 정의하는 방법을 알아보겠습니다.
기존 코드를 모두 지우고 다음과 같이 코드를 작성해보세요.

```typescript
function sum(x: number, y: number): number {
  return x + y;
}

sum(1, 2);
```

타입스크립트를 사용하면 다음과 같이 코드를 작성하는 과정에서 함수의 파라미터로 어떤 타입을 넣어야 하는지 바로 알 수 있답니다.

![img](https://i.imgur.com/ObAOm6n.png)

위 코드의 첫번째 줄의 가장 우측을 보면 `): number` 가 있지요? 이는 해당 함수의 결과물이 숫자라는것을 명시합니다.
만약에 이렇게 결과물이 number 라는 것을 명시해놓고 갑자기 null 을 반환한다면 오류가 뜨게 됩니다.

![img](https://i.imgur.com/BaZ9F8j.png)

이번에는 숫자 배열의 총합을 구하는 `sumArray` 라는 함수를 작성해볼까요?

#### src/practice.ts

```javascript
function sumArray(numbers: number[]): number {
  return numbers.reduce((acc, current) => acc + current, 0);
}

const total = sumArray([1, 2, 3, 4, 5]);
```

타입스크립트를 사용했을때 참 편리한 점은, 배열의 내장함수를 사용 할 때에도 타입 유추가 매우 잘 이루어진다는 것 입니다.

![img](https://i.imgur.com/xzJIkSY.png)

참고로 함수에서 만약 아무것도 반환하지 않아야 한다면 이를 반환 타입을 `void` 로 설정하면 됩니다.

```typescript
function returnNothing(): void {
  console.log('I am just saying hello world');
}
```

> 함수에 대하여 더 자세히 알아보기 [(링크)](https://typescript-kr.github.io/pages/Functions.html)

## interface 사용해보기

`interface`는 클래스 또는 객체를 위한 타입을 지정 할 때 사용되는 문법입니다.

#### 클래스에서 interface 를 implements 하기

우리가 클래스를 만들 때, 특정 조건을 준수해야 함을 명시하고 싶을 때 `interface` 를 사용하여 클래스가 가지고 있어야 할 요구사항을 설정합니다. 그리고 클래스를 선언 할 때 `implements` 키워드를 사용하여 해당 클래스가 특정 `interace`의 요구사항을 구현한다는 것을 명시합니다.

다음 코드를 따라 작성해보세요.

##### src/practice.ts

```typescript
// Shape 라는 interface 를 선언합니다.
interface Shape {
  getArea(): number; // Shape interface 에는 getArea 라는 함수가 꼭 있어야 하며 해당 함수의 반환값은 숫자입니다.
}

class Circle implements Shape {
  // `implements` 키워드를 사용하여 해당 클래스가 Shape interface 의 조건을 충족하겠다는 것을 명시합니다.

  radius: number; // 멤버 변수 radius 값을 설정합니다.

  constructor(radius: number) {
    this.radius = radius;
  }

  // 너비를 가져오는 함수를 구현합니다.
  getArea() {
    return this.radius * this.radius * Math.PI;
  }
}

class Rectangle implements Shape {
  width: number;
  height: number;
  constructor(width: number, height: number) {
    this.width = width;
    this.height = height;
  }
  getArea() {
    return this.width * this.height;
  }
}

const shapes: Shape[] = [new Circle(5), new Rectangle(10, 5)];

shapes.forEach(shape => {
  console.log(shape.getArea());
});
```

여기까지 코드를 작성하고 `yarn build` 명령어를 입력해보세요. 그 다음엔, `node dist/practice` 명령어를 입력하여 컴파일된 스크립트를 실행시켜보세요.

![img](https://i.imgur.com/xpyFzd9.png)

잘 작동하지요?

우리가 기존에 작성했던 클래스의 `constructor`쪽 코드를 보면

```typescript
  width: number;
  height: number;
  constructor(width: number, height: number) {
    this.width = width;
    this.height = height;
  }
```

이런식으로 `width`, `height` 멤버 변수를 선언한 다음에 `constructor` 에서 해당 값들을 하나 하나 설정해주었는데요, 타입스크립트에서는 `constructor` 의 파라미터 쪽에 `public` 또는 `private` [accessor](https://www.typescriptlang.org/docs/handbook/classes.html#accessors) 를 사용하면 직접 하나하나 설정해주는 작업을 생략해줄 수 있습니다.

##### src/practice.ts

```typescript
// Shape 라는 interface 를 선언합니다.
interface Shape {
  getArea(): number; // Shape interface 에는 getArea 라는 함수가 꼭 있어야 하며 해당 함수의 반환값은 숫자입니다.
}

class Circle implements Shape {
  // `implements` 키워드를 사용하여 해당 클래스가 Shape interface 의 조건을 충족하겠다는 것을 명시합니다.
  constructor(public radius: number) {
    this.radius = radius;
  }

  // 너비를 가져오는 함수를 구현합니다.
  getArea() {
    return this.radius * this.radius * Math.PI;
  }
}

class Rectangle implements Shape {
  constructor(private width: number, private height: number) {
    this.width = width;
    this.height = height;
  }
  getArea() {
    return this.width * this.height;
  }
}

const circle = new Circle(5);
const rectangle = new Rectangle(10, 5);

console.log(circle.radius); // 에러 없이 작동
console.log(rectangle.width); // width 가 private 이기 때문에 에러 발생!

const shapes: Shape[] = [new Circle(5), new Rectangle(10, 5)];

shapes.forEach(shape => {
  console.log(shape.getArea());
});
```

`public` accessor 는 특정 값이 클래스의 코드 밖에서도 조회 가능하다는 것을 의미합니다. 예를 들어서 `circle.width` 이런 식으로 코드를 작성하면 해당 값을 바로 조회 할 수 있습니다. 반면에 `rectangle.width` 를 조회 하려고 하면 컴파일 단계에서 에러가 발생해버립니다.

위 코드를 작성 후 `yarn build` 를 하시면 컴파일 에러가 날 것입니다. 한번 확인해보세요.

그리고, 문제가 되는 `console.log(rectangle.width);` 코드를 지우고, `yarn build` 명령어를 실행하여 코드를 컴파일 한뒤 `node dist/practice` 명령어를 실행해서 이전과 동일하게 작동되는지 확인해보세요.

## 일반 객체를 interface 로 타입 설정하기

이번에는 클래스가 아닌 일반 객체를 interface 를 사용하여 타입을 지정하는 방법을 알아보도록 하겠습니다.

```typescript
interface Person {
  name: string;
  age?: number; // 물음표가 들어갔다는 것은, 설정을 해도 되고 안해도 되는 값이라는 것을 의미합니다.
}
interface Developer {
  name: string;
  age?: number;
  skills: string[];
}

const person: Person = {
  name: '김사람',
  age: 20
};

const expert: Developer = {
  name: '김개발',
  skills: ['javascript', 'react']
};
```

지금 보면 Person 과 Developer 가 형태가 유사하지요? 이럴 땐 `interface` 를 선언 할 때 다른 `interface` 를 `extends` 해서 상속받을 수 있습니다.

##### src/practice.ts

```typescript
interface Person {
  name: string;
  age?: number; // 물음표가 들어갔다는 것은, 설정을 해도 되고 안해도 되는 값이라는 것을 의미합니다.
}
interface Developer extends Person {
  skills: string[];
}

const person: Person = {
  name: '김사람',
  age: 20
};

const expert: Developer = {
  name: '김개발',
  skills: ['javascript', 'react']
};

const people: Person[] = [person, expert];
```

> interface에 대한 더 자세한 내용 확인하기 [(링크)](https://typescript-kr.github.io/pages/Interfaces.html

## Type Alias 사용하기

`type`은 특정 타입에 별칭을 붙이는 용도로 사용합니다. 이를 사용하여 객체를 위한 타입을 설정할 수도 있고, 배열, 또는 그 어떤 타입이던 별칭을 지어줄 수 있습니다.

#### src/practice.ts

```typescript
type Person = {
  name: string;
  age?: number; // 물음표가 들어갔다는 것은, 설정을 해도 되고 안해도 되는 값이라는 것을 의미합니다.
};

// & 는 Intersection 으로서 두개 이상의 타입들을 합쳐줍니다.
// 참고: https://www.typescriptlang.org/docs/handbook/advanced-types.html#intersection-types
type Developer = Person & {
  skills: string[];
};

const person: Person = {
  name: '김사람'
};

const expert: Developer = {
  name: '김개발',
  skills: ['javascript', 'react']
};

type People = Person[]; // Person[] 를 이제 앞으로 People 이라는 타입으로 사용 할 수 있습니다.
const people: People = [person, expert];

type Color = 'red' | 'orange' | 'yellow';
const color: Color = 'red';
const colors: Color[] = ['red', 'orange'];
```

우리가 이번에 type 과 interface 를 배웠는데, 어떤 용도로 사용을 해야 할까요? 무엇이든 써도 상관 없는데 일관성 있게만 쓰시면 됩니다. 구버전의 타입스크립트에서는 `type` 과 `interface` 의 차이가 많이 존재했었는데 이제는 큰 차이는 없습니다. 다만 라이브러리를 작성하거나 다른 라이브러리를 위한 타입 지원 파일을 작성하게 될 때는 `interface`를 사용하는것이 권장 되고 있습니다.

이에 대한 자세한 내용은 다음 링크에 자세히 서술되어 있습니다.

- https://medium.com/@martin_hotell/interface-vs-type-alias-in-typescript-2-7-2a8f1777af4c
- https://joonsungum.github.io/post/2019-02-25-typescript-interface-and-type-alias/

## Generics

제네릭(Generics)은 타입스크립트에서 함수, 클래스, `interface`, `type`을 사용하게 될 때 여러 종류의 타입에 대하여 호환을 맞춰야 하는 상황에서 사용하는 문법입니다.

### 함수에서 Generics 사용하기

예를 들어서 우리가 객체 A 와 객체 B 를 합쳐주는 `merge` 라는 함수를 만든다고 가정해봅시다. 그런 상황에서는 A 와 B 가 어떤 타입이 올 지 모르기 떄문에 이런 상황에서는 `any` 라는 타입을 쓸 수도 있습니다.

```typescript
function merge(a: any, b: any): any {
  return {
    ...a,
    ...b
  };
}

const merged = merge({ foo: 1 }, { bar: 1 });
```

그런데, 이렇게 하면 타입추론이 모두 깨진거나 다름이 없습니다. 결과가 any 라는 것은 즉 merged 안에 무엇이 있는지 알 수 없다는 것 입니다.

![img](https://i.imgur.com/AVikBS7.png)

이런 상황에 제네릭을 사용하면 됩니다. 제네릭은 다음과 같이 사용합니다.

객체 예시

##### src/practice.ts

```typescript
function merge<A, B>(a: A, b: B): A & B {
  return {
    ...a,
    ...b
  };
}

const merged = merge({ foo: 1 }, { bar: 1 });
```

제네릭을 사용 할 때는 이렇게 `<T>` 처럼 꺽쇠 안에 타입의 이름을 넣어서 사용하며, 이렇게 설정을 해주면 제네릭에 해당하는 타입에는 뭐든지 들어올 수 있게 되면서도, 사용 할 때 타입이 깨지지 않게 됩니다. 만약 함수에 이렇게 제네릭을 사용하게 된다면 함수의 파라미터로 넣은 실제 값의 타입을 활용하게 된답니다.

또 다른 예시를 알아볼까요?

##### src/practice.ts

```typescript
function wrap<T>(param: T) {
  return {
    param
  }
}

const wrapped = wrap(10);
```

![img](https://i.imgur.com/OJmi5Xb.png)

타입이 깨지지 않았지요?

이렇게 함수에서 제너릭을 사용하면 파라미터로 다양한 타입을 넣을 수도 있고 타입 지원을 지켜낼 수 있습니다.

### interface 에서 Generics 사용하기

이번엔 `interface` 에서 제너릭을 사용하는 방법을 알아봅시다.

#### src/practice.ts

```typescript
interface Items<T> {
  list: T[];
}

const items: Items<string> = {
  list: ['a', 'b', 'c']
};
```

만약 `Items` 라는 타입을 사용하게 된다면, `Items` 타입을 지니고 있는 객체의 `list` 배열은 `string[]` 타입을 지니고 있게 됩니다. 이렇게 함으로써, `list`가 숫자배열인 경우, 문자열배열인경우, 객체배열, 또는 그 어떤 배열인 경우에도 하나의 `interface` 만을 사용하여 타입을 설정 할 수 있습니다.

#### Type alias 에서 Generic 사용하기

`type` 에서 제네릭을 사용하는 방법은 방금 `interface` 에서 제네릭을 사용 한 것과 매우 유사합니다. 방금 작성했던 코드를 `type`을 사용하는 코드로 변환해보겠습니다.

#### src/practice.ts

```typescript
type Items<T> = {
  list: T[];
};

const items: Items<string> = {
  list: ['a', 'b', 'c']
};
```

정말 비슷하죠?

### 클래스에서 Generics 사용하기

이번에는 클래스에서 제네릭을 사용해볼까요? Queue 라는 클래스를 만들어봅시다. Queue 는 데이터를 등록 할 수 있는 자료형이며, 먼저 등록(`enqueue`)한 항목을 먼저 뽑아올 수(`dequeue`) 있는 성질을 가지고 있습니다. 실생활에서 접할 수 있는 간단한 Queue 예시는 대기 줄입니다. 대기 줄에서는 (누가 새치기를 하지 않는 이상) 가장 먼저 온 사람이 먼저 들어가죠? 이런 로직이 바로 Queue 입니다.

이 Queue를 타입스크립트로 구현해보겠습니다.

#### src/practice.ts

```typescript
class Queue<T> {
  list: T[] = [];
  get length() {
    return this.list.length;
  }
  enqueue(item: T) {
    this.list.push(item);
  }
  dequeue() {
    return this.list.shift();
  }
}

const queue = new Queue<number>();
queue.enqueue(0);
queue.enqueue(1);
queue.enqueue(2);
queue.enqueue(3);
queue.enqueue(4);
console.log(queue.dequeue());
console.log(queue.dequeue());
console.log(queue.dequeue());
console.log(queue.dequeue());
console.log(queue.dequeue());
```

이제 해당 코드를 컴파일하고 실행해보세요.

```bash
$ yarn build
$ node ./dist/practice

0
1
2
3
4
```

잘 작동하나요? 이 Queue 에서는 제너릭을 사용하여 다양한 원소 타입으로 이루어진 Queue의 타입을 설정할 수 있습니다.
예를 들어서 `Queue` 이라고 하면 문자열로 이루어진 Queue의 타입이 되겠지요?

> Generic 에 대해서 더 자세히 알아보기 [(링크)](https://typescript-kr.github.io/pages/Generics.html)










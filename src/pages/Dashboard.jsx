import { useEffect, useState } from 'react';
import Navbar from '../component/Navbar';

export default function Dashboard() {
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const timer = setTimeout(() => {
            setLoading(false);
        }, 2000);

        return () => clearTimeout(timer);
    }, []);

    const Loading = () => (
        <div className="flex items-center justify-center min-h-screen bg-[#F7F1FE] transition-opacity duration-[2000ms]">
            <div className="flex space-x-2">
                <div className="dot"></div>
                <div className="dot"></div>
                <div className="dot"></div>
            </div>
            <style jsx>{`
        .dot {
          width: 15px;
          height: 15px;
          border-radius: 50%;
          background-color: #3498db;
          animation: bounce 3s infinite alternate ease-in-out;
        }

        .dot:nth-child(2) {
          animation-delay: 0.5s;
        }

        .dot:nth-child(3) {
          animation-delay: 1s;
        }

        @keyframes bounce {
          0% {
            transform: translateY(0);
          }
          50% {
            transform: translateY(-20px);
          }
          100% {
            transform: translateY(0);
          }
        }
      `}</style>
        </div>
    );

    if (loading) {
        return <Loading />;
    }

    return (
        <div className="min-h-screen bg-[#F7F1FE] transition-opacity duration-[2000ms]">
            <Navbar />
            <div className="p-6">
                <p className="text-gray-700">
                    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis nec est pretium, dictum justo ut, convallis neque. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Aenean porttitor iaculis ullamcorper. Mauris dictum pretium ultrices. Curabitur vel massa vitae est mattis ullamcorper sed quis neque. Nulla dapibus tristique lobortis. Sed hendrerit libero et diam accumsan eleifend.

                    Duis id dapibus nibh. Vestibulum pretium lectus vitae gravida accumsan. Aliquam erat volutpat. Pellentesque purus diam, ornare non libero mattis, lacinia mollis ipsum. Donec urna nulla, faucibus vel efficitur ut, venenatis quis nisi. Donec ac leo ac ex mollis auctor. In sed accumsan felis, vel pulvinar sem. Nam quis rutrum quam, quis blandit urna. Duis in pulvinar magna.

                    Pellentesque tempor, est ac vehicula consequat, turpis leo suscipit neque, at ornare sapien elit quis leo. Cras id porta odio. In auctor sem quis ex convallis, ac volutpat ipsum imperdiet. Integer vitae feugiat felis. Aenean vel nulla vitae est lobortis porttitor eget hendrerit odio. Vestibulum eu neque et velit fermentum tempor vel et lacus. Nunc sit amet magna erat. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.

                    Sed turpis arcu, vestibulum sit amet placerat vel, pellentesque et quam. Nunc sed euismod lacus. Pellentesque rutrum mattis augue ac rhoncus. In hac habitasse platea dictumst. Vestibulum quis egestas velit, id vulputate leo. Praesent nec laoreet arcu, at ultrices arcu. Fusce hendrerit, ligula in vestibulum finibus, lectus dolor varius mi, quis tempus quam erat viverra dolor. Nunc tempus iaculis accumsan. Aliquam augue metus, sagittis nec rhoncus non, eleifend in risus. Donec vitae odio molestie, venenatis velit in, pretium enim. Vestibulum posuere tortor sit amet ligula vestibulum, a vulputate diam dictum. Aenean rhoncus sit amet risus vitae varius.

                    Nunc elit augue, porttitor sed turpis vel, aliquam interdum mi. Cras semper id nibh a imperdiet. Aliquam neque elit, aliquam sed mattis eu, varius et enim. Vivamus a scelerisque lorem, nec interdum nisi. Aliquam in erat nec nunc rhoncus imperdiet ut non odio. Aenean in ultrices justo. Donec consequat, tortor ac sollicitudin rhoncus, magna odio commodo urna, ut pulvinar ipsum nulla nec tellus. In eget justo mi. Maecenas tempus vestibulum lectus et semper. Nunc eget viverra mi. Vivamus tempor posuere justo, sit amet pulvinar lectus mattis eu. Fusce velit turpis, efficitur quis consequat aliquet, interdum eu dui. Phasellus vitae magna aliquam, dapibus dolor et, dapibus dolor.

                    Aliquam bibendum sodales justo, ultricies vulputate elit hendrerit et. Curabitur ultrices sagittis lectus eget posuere. Proin a nulla vestibulum diam eleifend posuere bibendum ac mauris. Vivamus maximus ultrices quam dapibus varius. Nam sapien felis, lacinia in rhoncus et, dictum eu ante. Suspendisse rhoncus fringilla efficitur. Maecenas feugiat diam nec urna ultrices, id vestibulum urna auctor. Donec elementum elementum tortor, sed dapibus libero facilisis vel. Ut laoreet, odio sed rutrum placerat, felis urna tristique nunc, aliquam luctus diam magna ut dolor. Aenean lacinia justo vel ante dapibus blandit a et risus. Curabitur lacinia vehicula nunc tempor porta. Sed fringilla tortor nec nisi tincidunt, et sagittis justo elementum. Curabitur consectetur mollis aliquet. Duis ut eleifend neque. Duis et urna sapien.

                    Phasellus vitae molestie est. Nam nec dictum massa. Etiam quis nisi rutrum, lacinia risus id, consequat felis. Mauris vehicula, massa quis laoreet egestas, nulla sem pulvinar elit, et hendrerit justo arcu id tellus. Donec tortor ante, auctor eget est at, vulputate tempus neque. Etiam vel nulla tempor, auctor metus vel, suscipit dui. Curabitur sem ante, pellentesque ut iaculis sed, dictum a elit. Donec at imperdiet augue. Cras nec efficitur sapien, et tristique est. Cras ultrices nibh vel mi finibus maximus. Cras sollicitudin, ante in pellentesque scelerisque, eros odio dictum dolor, ac cursus nisl nisi ut leo.

                    Nam augue ex, mollis nec orci ut, mollis lobortis eros. Etiam vestibulum ultrices ipsum, non semper magna tristique id. Fusce ut nulla sed orci aliquam lobortis ac a nisi. Nulla facilisi. Interdum et malesuada fames ac ante ipsum primis in faucibus. Quisque at elementum risus, non tristique est. Vestibulum placerat, ante a tempor maximus, dolor eros posuere eros, a vehicula ante nisl id nisl.

                    Nam interdum viverra eros, at gravida nibh dignissim vitae. Cras vestibulum ligula id consequat sagittis. Donec ac odio a eros aliquam imperdiet. Quisque varius quam at mauris condimentum, in rutrum ante consequat. Nunc et elementum quam. Morbi ligula nisi, imperdiet in diam non, tristique euismod erat. Proin lacus tortor, laoreet ut orci ut, iaculis facilisis nunc. Interdum et malesuada fames ac ante ipsum primis in faucibus. Maecenas eu molestie est. In dignissim mattis quam, sit amet congue ligula volutpat a. Morbi mi arcu, fermentum id justo eu, dapibus malesuada sem. Integer auctor maximus viverra. Suspendisse massa massa, fringilla sit amet felis sit amet, rutrum dictum dui. Phasellus nisl lectus, volutpat in purus id, egestas porttitor ante. Nulla facilisi. Curabitur sit amet auctor nunc.

                    Vestibulum libero arcu, sodales ac nulla id, tincidunt vehicula risus. Mauris semper porta eleifend. Proin suscipit convallis pretium. Integer tincidunt vestibulum ultricies. Praesent ac augue nec massa eleifend venenatis id ut enim. In consequat, est non sagittis accumsan, elit augue fermentum nunc, quis malesuada sapien lacus in lectus. Nunc placerat gravida cursus. In hac habitasse platea dictumst. Fusce sed nisi ut nulla elementum iaculis non a nisi. Maecenas sed odio sed augue iaculis malesuada in et metus. Donec sit amet tortor et nunc porta maximus. Mauris sit amet dui magna. Nunc leo eros, dictum quis bibendum eget, condimentum eget sapien. Praesent nibh lacus, dapibus quis eros eu, tristique iaculis sem.

                    Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Integer bibendum ligula a massa ultrices, eget auctor risus suscipit. Quisque vitae scelerisque enim, at blandit sapien. Sed in metus bibendum, tempus metus quis, scelerisque urna. Pellentesque eget viverra turpis. Nullam sit amet turpis elementum, interdum massa ut, iaculis dolor. Sed consectetur tincidunt viverra.

                    Fusce tempus quis tortor a sagittis. Ut tincidunt elit vel commodo cursus. In urna orci, maximus id turpis id, pellentesque gravida nunc. Morbi a nibh sed tortor feugiat maximus. Nam lobortis, enim vel scelerisque interdum, nulla nunc sagittis tortor, a vulputate sem turpis nec ipsum. Nulla porta vel augue non egestas. Donec eu est vel nibh suscipit ultrices id a quam. Ut consequat, ligula id iaculis pellentesque, nisl dolor venenatis tellus, id porttitor felis sapien ut risus. Proin sit amet urna quis lectus auctor imperdiet et eget dolor. Duis non ex id odio efficitur pretium.

                    Cras pulvinar odio id leo tempor, at convallis nisl fermentum. Vestibulum vulputate, nibh sed euismod maximus, lacus arcu consectetur velit, in vehicula lectus tortor vestibulum urna. Suspendisse mi ipsum, facilisis eget luctus quis, facilisis ut nibh. Suspendisse sed velit at dui congue facilisis ut et metus. Cras blandit diam vitae libero consectetur, tincidunt aliquet libero porta. Maecenas hendrerit congue mauris non consectetur. Integer consectetur tortor non tempor molestie.

                    Pellentesque varius rutrum aliquet. Suspendisse et ultrices lacus. Vestibulum dictum ipsum orci, in elementum nunc mollis sit amet. Suspendisse a lacus nibh. Nulla facilisi. Cras eu justo non nulla fermentum mollis. Vivamus ut facilisis leo. Nam consectetur laoreet lectus, et rutrum nulla porta vel. Nam nulla sem, aliquam sit amet nibh quis, lobortis molestie nisl. Integer at nunc rutrum, volutpat sapien nec, volutpat tortor. Praesent euismod est id risus vestibulum, at blandit lorem tristique. Mauris tincidunt at arcu eget tincidunt. Etiam vel massa elementum, euismod nunc lobortis, varius dui. Donec sed sem non magna mollis faucibus ut quis felis.

                    Suspendisse porta tortor a orci congue lacinia. Nam tempus lorem nisl, ac luctus sapien ornare non. Nullam mattis finibus tristique. Fusce eu massa est. Vestibulum eu ullamcorper turpis, non sollicitudin elit. In id velit non lectus placerat mollis. Curabitur eget elit ultrices, venenatis nulla sit amet, dictum magna. Morbi interdum posuere nibh, quis mollis sapien cursus vitae. Proin suscipit vel turpis vitae pretium. Sed bibendum risus eget nisi consectetur blandit. Integer sem nisi, luctus a placerat et, pulvinar eu ligula. Duis turpis quam, vehicula sed neque ut, pharetra laoreet nunc.

                    Integer dui urna, mollis eu purus at, egestas sodales eros. Ut vulputate lobortis ipsum ac euismod. Nam placerat, enim ut condimentum sodales, elit massa imperdiet urna, non tincidunt nulla ipsum commodo nibh. Proin imperdiet metus neque, sit amet pretium ante tempor ut. Donec congue lorem tortor, non semper eros ornare sed. Etiam tincidunt sem nec elit imperdiet, non hendrerit erat posuere. Nunc lacus augue, scelerisque quis mattis non, bibendum et elit. Pellentesque vitae eros vitae nibh tincidunt aliquam. Suspendisse rutrum risus nunc, eget lobortis mi pulvinar eget. Pellentesque sodales, lorem et dapibus rutrum, justo sapien suscipit velit, malesuada sollicitudin nunc tortor facilisis erat. Quisque eu libero venenatis, accumsan tellus rutrum, feugiat orci. Fusce semper dolor in bibendum commodo. Quisque commodo sed risus ac mollis. Duis rhoncus condimentum felis a ullamcorper.

                    Pellentesque tincidunt elit et nisi rutrum laoreet. Ut ultrices id erat vitae varius. Etiam aliquam ornare eros sit amet blandit. Fusce vulputate iaculis sapien. Aliquam sapien est, ultrices vel enim sit amet, auctor aliquam lorem. Sed pretium dolor vitae sem ullamcorper laoreet. Sed at sodales lectus, a pellentesque tellus. Fusce congue lacus laoreet, hendrerit lorem at, suscipit nisi. Morbi nisi est, consectetur ut nibh at, auctor pulvinar velit. Mauris egestas, quam non bibendum venenatis, libero augue bibendum est, eu finibus quam lectus quis nibh. Nulla facilisi. Ut fringilla, sem non tincidunt accumsan, arcu ex placerat nisi, a tincidunt lorem massa vel sapien. In fermentum fringilla convallis.

                    Ut vel lacus rhoncus dui faucibus tempor quis molestie nisl. Nulla vitae mauris tempus, vulputate dolor ac, convallis enim. Quisque dictum sem sodales, tincidunt purus quis, pellentesque nulla. Suspendisse id est ac ex pellentesque finibus ut at sem. Nunc sollicitudin volutpat imperdiet. Vivamus purus purus, dictum vitae imperdiet sed, malesuada eu nunc. Duis aliquam, metus id iaculis tempus, odio magna finibus arcu, eget aliquam lacus felis maximus enim. Suspendisse bibendum nunc sed pharetra finibus. Donec vel mi elit. Nulla faucibus erat id ex fermentum, vel iaculis quam bibendum. Nunc erat leo, ullamcorper sit amet tempor et, sollicitudin eget neque.

                    Duis elementum sollicitudin tellus. Nunc commodo porta erat eget rhoncus. Sed a tellus lobortis, posuere ipsum vel, volutpat ex. Nam hendrerit imperdiet est vel lacinia. Ut viverra lacus tellus, in feugiat sapien consectetur nec. Cras vel tortor rutrum, pretium dui nec, consectetur metus. Integer at ex nulla. Maecenas vel magna vitae ex aliquam cursus. Quisque non lobortis metus. In bibendum, lorem eu porta aliquam, libero augue commodo arcu, at tristique enim purus nec libero. Praesent eget luctus nunc. Etiam ac urna sollicitudin, tempus ante non, rutrum nisl. Aenean egestas fermentum fringilla.

                    Duis a massa non dui accumsan finibus nec nec turpis. Maecenas eget blandit lorem. Proin felis risus, malesuada id arcu quis, congue egestas ante. Curabitur sed sollicitudin nisi. Vivamus varius consectetur purus a placerat. Aenean eget nisl eget lorem maximus blandit ut et nunc. In nec felis dui. Vestibulum cursus sapien eu felis viverra mollis at vel metus. Proin felis purus, imperdiet et nibh imperdiet, congue imperdiet nisi. Morbi aliquet cursus nibh non rhoncus. Mauris at diam arcu. Phasellus molestie lacus leo, vitae ullamcorper ipsum imperdiet in. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin turpis lectus, mattis a laoreet a, semper eget nulla. Interdum et malesuada fames ac ante ipsum primis in faucibus. </p>
            </div>
        </div>
    );
}
